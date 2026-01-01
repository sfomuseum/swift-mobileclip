import ArgumentParser
import Foundation
import Logging
import GRPCCore
import GRPCNIOTransportHTTP2
import Logging
import SwiftProtobuf

struct Image: AsyncParsableCommand {
    static let configuration = CommandConfiguration(abstract: "...")
    
    @Option(help: "The host name for the gRPC server.")
    var host: String = "127.0.0.1"
    
    @Option(help: "The port for the gRPC server.")
    var port: Int = 8080
    
    @Option(help: "...")
    var model: String = "s0"
    
    // @Option(help: "Log events to system log files")
    // var logfile: Bool = false
    
    @Option(help: "Enable verbose logging")
    var verbose: Bool = false
    
    @Option(help: "The image file to derive embeddings for.")
    var image: String
    
    func run() async throws {
        
        var logger = Logger(label: "org.sfomuseum.embeddings.grpc.image")

        if verbose {
            logger.logLevel = .debug
        }
        
        try await withGRPCClient(
            
            transport: .http2NIOPosix(
                target: .ipv4(address: self.host, port: self.port),
                transportSecurity: .plaintext
            )
            
        ) { client in
            
            logger.info("Derive image embeddings")

            let image_url = URL(filePath: image)
            let image_basename = image_url.lastPathComponent
            let body = try Data(contentsOf: image_url)
                                    
            let server = OrgSfomuseumEmbeddingsService_EmbeddingsService.Client(wrapping: client)
            
            var req = OrgSfomuseumEmbeddingsService_EmbeddingsRequest()
            req.id = image_basename
            req.model = model
            req.body = body
            
            let rsp = try await server.computeImageEmbeddings(req)
            
            do {
                try writeResponseAsJSON(rsp: rsp)
            } catch {
                logger.error("Failed to marshal response \(error)")
                throw error
            }
        }
        
    }
    
}
