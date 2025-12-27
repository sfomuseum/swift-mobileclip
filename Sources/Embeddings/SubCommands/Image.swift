import ArgumentParser
import Logging
import MobileCLIP


struct Image: AsyncParsableCommand {
    static let configuration = CommandConfiguration(abstract: "Parse the text of a wall label in to JSON-encoded structured data.")
    
    @Option(help: "The parser scheme is to use for parsing wall label text.")
    var encoder_uri: String = "s0://"
    
    @Option(help: "The path to the image to derive embeddings for.")
    var path: String
    
    @Option(help: "Enable verbose logging")
    var verbose: Bool = false
    
    func run() async throws {
        
        var logger = Logger(label: "org.sfomuseum.embeddings")
        
        if verbose {
            logger.logLevel = .debug
        }
        
        guard let im = loadCGImage(at: path) else {
            fatalError("SAD")
        }
        
        var encoder: CLIPEncoder
        
        do {
            encoder = try NewClipEncoder(uri: encoder_uri)
        } catch {
            throw error
        }
        
        do {
            let emb = try await ComputeImageEmbeddings(model: encoder, image: im)
            print("HI \(emb)")
        } catch {
            throw error
        }
    }
}

