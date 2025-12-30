import ArgumentParser
import Logging
import MobileCLIP
import CoreGraphics

struct Image: AsyncParsableCommand {
    static let configuration = CommandConfiguration(abstract: "Derive vector embeddings for an image.")
    
    @Option(help: "The URI for MobileCLIP encoder to use. URIs take the form of {SCHEME}://{OPTIONAL_PATH} where {SCHEME} is one of s0,s1,s2 or blt and {OPTIONAL_PATH} is the path to a local directory containing compiled MobileCLIP CoreML model files. If {OPTIONAL_PATH} is empty then models will loaded from the application's default Bundle.")
    var encoder_uri: String = "s0://"
    
    @Option(help: "The path to the image to derive embeddings from.")
    var path: String
    
    @Option(help: "Enable verbose logging")
    var verbose: Bool = false
    
    func run() async throws {
        
        var logger = Logger(label: "org.sfomuseum.embeddings.image")
        
        if verbose {
            logger.logLevel = .debug
        }
        
        var im: CGImage
        var encoder: CLIPEncoder

        do {
            im = try loadCGImage(at: path)
            encoder = try NewClipEncoder(uri: encoder_uri)
        } catch {
            logger.error("Failed to create new encoder, \(error)")
            throw error
        }

        let rsp =  await ComputeImageEmbeddings(encoder: encoder, image: im)

        switch rsp {
        case .success(let emb):
            try writeEmbeddingsAsJSON(results: emb)
        case .failure(let error):
            logger.error("Failed to encode embeddings, \(error)")
            throw error
        }
    }
}

