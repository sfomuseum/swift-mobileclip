import ArgumentParser
import Foundation
import Logging
import GRPCCore
import GRPCNIOTransportHTTP2
import Logging

struct Client: AsyncParsableCommand {
    static let configuration = CommandConfiguration(abstract: "...")
    
    @Option(help: "The host name for the gRPC server.")
    var host: String = "127.0.0.1"
    
    @Option(help: "The port for the gRPC server.")
    var port: Int = 8080
    
    // @Option(help: "Log events to system log files")
    // var logfile: Bool = false
    
    @Option(help: "Enable verbose logging")
    var verbose: Bool = false
    
    @Option(help: "The image file to derive embeddings for.")
    var image: String
    
    @Option(help: "Display this message.")
    var combined: Bool = false
    
    func run() async throws {
        
        var logger = Logger(label: "org.sfomuseum.embeddings.grpc.client")

        if verbose {
            logger.logLevel = .debug
        }
        
        try await withGRPCClient(
            
            transport: .http2NIOPosix(
                target: .ipv4(address: self.host, port: self.port),
                transportSecurity: .plaintext
            )
            
        ) { client in
            
            let image_url = URL(filePath: image)
            let image_basename = image_url.lastPathComponent
            let body = try Data(contentsOf: image_url)
                        
            logger.info("Derive image embeddings \(image_basename)")
            
            let server = OrgSfomuseumEmbeddingsService_EmbeddingsService.Client(wrapping: client)
            
            var req = OrgSfomuseumEmbeddingsService_EmbeddingsRequest()
            req.id = image_basename
            req.body = body
            
            let rsp = try await server.computeImageEmbeddings(req)
            
            let encoder = JSONEncoder()
            encoder.outputFormatting = .sortedKeys
            
            do {
                let data = try encoder.encode(rsp.embeddings)
                FileHandle.standardOutput.write(data)
            } catch {
                throw error
            }
        }
        
    }
    
}
