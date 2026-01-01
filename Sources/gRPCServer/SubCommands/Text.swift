import ArgumentParser
import Foundation
import Logging
import GRPCCore
import GRPCNIOTransportHTTP2
import Logging
import MobileCLIP

struct Text: AsyncParsableCommand {
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
    
    @Argument(help: "The text to generate embeddings for. If \"-\" then data is read from STDIN. If the first argument is a valid path to a local file then the text of that file will be used. Otherwise all remaining arguments will be concatenated (with a space) and used as the text to generate embeddings for.")
    var args: [String]
    
    func run() async throws {
        
        var logger = Logger(label: "org.sfomuseum.embeddings.grpc.text")

        if verbose {
            logger.logLevel = .debug
        }
        
        try await withGRPCClient(
            
            transport: .http2NIOPosix(
                target: .ipv4(address: self.host, port: self.port),
                transportSecurity: .plaintext
            )
            
        ) { client in
            
            logger.info("Derive text embeddings")
            
            var input: Data
            
            do {
                 input = try TextFromArgsAsData(args: args)
            } catch {
                logger.error("Failed to derive text from args \(error)")
                throw error
            }
            
            var req = OrgSfomuseumEmbeddingsService_EmbeddingsRequest()
            req.id = ""
            req.model = model
            req.body = input
            
            let server = OrgSfomuseumEmbeddingsService_EmbeddingsService.Client(wrapping: client)

            let rsp = try await server.computeTextEmbeddings(req)
            
            do {
                try writeResponseAsJSON(rsp: rsp)
            } catch {
                logger.error("Failed to marshal response \(error)")
                throw error
            }
        }
        
    }
    
}
