import ArgumentParser

import Logging
import MobileCLIP

enum ParseErrors: Error {
    case invalidParser
    case stringifyError
}

struct Text: AsyncParsableCommand {
    static let configuration = CommandConfiguration(abstract: "Parse the text of a wall label in to JSON-encoded structured data.")
    
    @Option(help: "The parser scheme is to use for parsing wall label text.")
    var encoder_uri: String = "s0://"
    
    
    @Option(help: "Enable verbose logging")
    var verbose: Bool = false
    
    func run() async throws {
        
        var logger = Logger(label: "org.sfomuseum.embeddings")

        if verbose {
            logger.logLevel = .debug
        }
        
        let tokenizer = CLIPTokenizer()
        var encoder: CLIPEncoder
        
        do {
            encoder = try NewClipEncoder(uri: encoder_uri)
        } catch {
            throw error
        }
           
        let input = [ "Hello", "world "]
        
        let emb = await ComputeTextEmbeddings(model: encoder, tokenizer: tokenizer, promptArr: input)
        print("HI \(emb)")
        
    }
}
