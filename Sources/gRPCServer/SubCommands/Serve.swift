import ArgumentParser
import Foundation
import Logging
import MobileCLIP
import GRPCCore
import GRPCNIOTransportHTTP2
import GRPCProtobuf
import CoreGraphics
import CoreGraphicsImage

enum ServeError: Error, LocalizedError {
    case invalidEncoderURI
    case invalidText
    
    public var errorDescription: String? {
        switch self {
        case .invalidEncoderURI:
            return "Failed to construct encoder URI from model(s)."
        case .invalidText:
            return "Input text is invalid."
        }
    }
}

struct Serve: AsyncParsableCommand {
    static let configuration = CommandConfiguration(abstract: "gRPC server for deriving vector embeddings from an image or text.")
    
    @Option(help: "The path to the directory containing the MobileCLIP \".modelc\" files. If empty then it will be assumed that those models have been bundled as application resources and will be available from the main \"Bundle\".")
    var models: String = ""
    
    @Option(help: "The host name to listen for new connections")
    var host: String = "127.0.0.1"
    
    @Option(help: "The port to listen on")
    var port: Int = 8080
    
    @Option(help: "Sets the maximum message size in bytes the server may receive. If 0 then the swift-grpc defaults will be used.")
    var max_receive_message_length = 0
    
    @Option(help: "The TLS certificate chain to use for encrypted connections")
    var tls_certificate: String = ""
    
    @Option(help: "The TLS private key to use for encrypted connections")
    var tls_key: String = ""
    
    @Option(help: "Enable verbose logging")
    var verbose: Bool = false
    
    func run() async throws {
        
        var logger = Logger(label: "org.sfomuseum.embeddings.grpc.server")

        if verbose {
            logger.logLevel = .debug
        }
        
        var transportSecurity = HTTP2ServerTransport.Posix.TransportSecurity.plaintext
        
        // https://github.com/grpc/grpc-swift/issues/2219
        
        if tls_certificate != "" && tls_key != ""  {
            
            let certSource:  TLSConfig.CertificateSource   = .file(path: tls_certificate, format: .pem)
            let keySource:   TLSConfig.PrivateKeySource    = .file(path: tls_key, format: .pem)
            
            transportSecurity = HTTP2ServerTransport.Posix.TransportSecurity.tls(
                certificateChain: [ certSource ],
                privateKey: keySource,
            )
        }
        
        // Keepalive configs necessary because this:
        // https://github.com/grpc/grpc-swift-2/issues/5#issuecomment-2984421768
        
        // https://github.com/grpc/grpc-swift-nio-transport/blob/15f9bfee04d19c1d720f34c6c6b3e8214bf557db/Sources/GRPCNIOTransportCore/Server/HTTP2ServerTransport.swift#L85
        
        let client_keepalive = HTTP2ServerTransport.Config.ClientKeepaliveBehavior.init(
            // Default is 300 (5 minutes)
            minPingIntervalWithoutCalls: .seconds(1),
            // Default is false
            allowWithoutCalls: true
        )
        
        // https://github.com/grpc/grpc-swift-nio-transport/blob/15f9bfee04d19c1d720f34c6c6b3e8214bf557db/Sources/GRPCNIOTransportCore/Server/HTTP2ServerTransport.swift#L52
        
        var server_keepalive = HTTP2ServerTransport.Config.Keepalive.defaults
        server_keepalive.clientBehavior = client_keepalive
        
        let transport = HTTP2ServerTransport.Posix(
            address: .ipv4(host: self.host, port: self.port),
            transportSecurity: transportSecurity,
            config: .defaults { config in
                if max_receive_message_length > 0 {
                    config.rpc.maxRequestPayloadSize = max_receive_message_length
                }
                config.connection.keepalive = server_keepalive
              }
        )
        
        let service = EmbeddingsService(models: models, logger: logger)
        let server = GRPCServer(transport: transport, services: [service])
                
        try await withThrowingDiscardingTaskGroup { group in
            // Why does this time out?
            // let address = try await transport.listeningAddress
            logger.info("listening for requests on \(self.host):\(self.port)")
            group.addTask { try await server.serve() }
        }
    }
}

struct EmbeddingsService: OrgSfomuseumEmbeddingsService_EmbeddingsService.SimpleServiceProtocol {
    
    var logger: Logger
    var models: String
    
    // Fails all the Sendable checks...
    // var encoders: [String: CLIPEncoder] = [:]
    
    init(models: String, logger: Logger) {
        self.logger = logger
        self.models = models
    }

    func newEncoder(model: String) throws -> CLIPEncoder {
        
        var components = URLComponents()
        components.scheme = model
        
        if self.models != "" {
            components.path = self.models
        }
        
        guard let encoder_uri = components.url else {
            throw ServeError.invalidEncoderURI
        }
        
        logger.info("Create encoder for \(encoder_uri.absoluteString)")
        
        do {
            return try NewClipEncoder(uri: encoder_uri.absoluteString)
        } catch {
            logger.error("Failed to create new encoder, \(error)")
            throw error
        }
    }
    
    func computeImageEmbeddings(request: OrgSfomuseumEmbeddingsService_EmbeddingsRequest, context: GRPCCore.ServerContext) async throws -> OrgSfomuseumEmbeddingsService_EmbeddingsResponse {
        
        var encoder: CLIPEncoder
        var im: CGImage

        do {
            encoder = try self.newEncoder(model: request.model)
        } catch {
            throw error
        }

        let temporaryDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory(),
                                        isDirectory: true)
        
        let temporaryFilename = ProcessInfo().globallyUniqueString
        
        let temporaryFileURL =
        temporaryDirectoryURL.appendingPathComponent(temporaryFilename)
        
        try request.body.write(to: temporaryFileURL,
                               options: .atomic)
                
        defer {
            do {
                try FileManager.default.removeItem(at: temporaryFileURL)
            } catch {
                self.logger.error("Failed to remove temporary file at \(temporaryFileURL), \(error)")
            }
        }
                
        let im_rsp = CoreGraphicsImage.LoadFromURL(url: temporaryFileURL)
        
        switch im_rsp {
        case .failure(let error):
            self.logger.error("Failed to load image from \(temporaryFileURL), \(error)")
            throw(error)
        case .success(let cg_im):
            im = cg_im
        }
        
        let rsp = await ComputeImageEmbeddings(encoder: encoder, image: im)
        
        switch rsp {
        case .success(let emb):
            
            let rsp = OrgSfomuseumEmbeddingsService_EmbeddingsResponse.with{
                $0.id = request.id
                $0.model = emb.model
                $0.embeddings = emb.embeddings
                $0.dimensions = Int32(emb.dimensions)
                $0.created = emb.created
            }
            
            return rsp
            
        case .failure(let error):
            logger.error("Failed to encode embeddings, \(error)")
            throw error
        }
    }
    
    func computeTextEmbeddings(request: OrgSfomuseumEmbeddingsService_EmbeddingsRequest, context: GRPCCore.ServerContext) async throws -> OrgSfomuseumEmbeddingsService_EmbeddingsResponse {
        
        let tokenizer = CLIPTokenizer()
        var encoder: CLIPEncoder
        
        do {
            encoder = try self.newEncoder(model: request.model)
        } catch {
            throw error
        }

        guard let text = String(data: request.body, encoding: .utf8) else {
            logger.error("Invalid message body")
            throw ServeError.invalidText
        }

        let rsp = await ComputeTextEmbeddings(encoder: encoder, tokenizer: tokenizer, text: text)
        
        switch rsp {
        case .success(let emb):
            
            let rsp = OrgSfomuseumEmbeddingsService_EmbeddingsResponse.with{
                $0.id = request.id
                $0.model = emb.model
                $0.embeddings = emb.embeddings
                $0.dimensions = Int32(emb.dimensions)
                $0.created = emb.created
            }
            
            return rsp
            
        case .failure(let error):
            logger.error("Failed to encode embeddings, \(error)")
            throw error
        }
    }
    
}
