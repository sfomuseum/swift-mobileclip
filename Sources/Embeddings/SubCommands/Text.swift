import ArgumentParser
import Foundation
import Logging
import MobileCLIP

enum TextErrors: Error {
    case missingInput
    case isDirectory
}

struct Text: AsyncParsableCommand {
    static let configuration = CommandConfiguration(abstract: "Derive vector embeddings for a text.")
    
    @Option(help: "The URI for MobileCLIP encoder to use. URIs take the form of {SCHEME}://{OPTIONAL_PATH} where {SCHEME} is one of s0,s1,s2 or blt and {OPTIONAL_PATH} is the path to a local directory containing compiled MobileCLIP CoreML model files. If {OPTIONAL_PATH} is empty then models will loaded from the application's default Bundle.")
    var encoder_uri: String = "s0://"
    
    @Option(help: "Enable verbose logging")
    var verbose: Bool = false
    
    @Argument(help: "The text to generate embeddings for. If \"-\" then data is read from STDIN. If the first argument is a valid path to a local file then the text of that file will be used. Otherwise all remaining arguments will be concatenated (with a space) and used as the text to generate embeddings for.")
    var args: [String]
    
    func run() async throws {
        
        var logger = Logger(label: "org.sfomuseum.embeddings.text")

        if verbose {
            logger.logLevel = .debug
        }
        
        let tokenizer = CLIPTokenizer()
        var encoder: CLIPEncoder
        
        do {
            encoder = try NewClipEncoder(uri: encoder_uri)
        } catch {
            logger.error("Failed to create new encoder, \(error)")
            throw error
        }
           
        var input: String = ""
        
        switch args.count {
        case 0:
            throw TextErrors.missingInput
        case 1:
            
            switch args[0] {
            case "-":
                
                let data = FileHandle.standardInput.readDataToEndOfFile()
                input = String(data: data, encoding: .utf8) ?? ""
                
            default:
                
                var isDir: ObjCBool = false
                let exists = FileManager.default.fileExists(atPath: args[0], isDirectory: &isDir)
                
                if !exists {
                    input = args[0]
                } else {
                                        
                    if isDir.boolValue {
                        logger.error("Path is a directory")
                        throw TextErrors.isDirectory
                    }
                    
                    do {
                        input = try String(contentsOfFile: args[0], encoding: .utf8)
                    } catch {
                        logger.error("Failed to read file, \(error)")
                        throw error
                    }
                }

            }
            
        default:
            input = args.joined(separator: " ")
        }
                
        guard input != "" else {
            throw TextErrors.missingInput
        }
        
        let rsp = await ComputeTextEmbeddings(encoder: encoder, tokenizer: tokenizer, text: input)
        
        switch rsp {
        case .success(let emb):
            try writeEmbeddingsAsJSON(results: emb)
        case .failure(let error):
            logger.error("Failed to encode embeddings, \(error)")
            throw error
        }
        
    }
}
