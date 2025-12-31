import ArgumentParser
import Foundation
import Logging
import MobileCLIP

enum TextErrors: Error {
    case missingInput
    case isDirectory
}

struct gRPCServer: AsyncParsableCommand {
    static let configuration = CommandConfiguration(abstract: "Derive vector embeddings for a text.")
    
    @Option(help: "The URI for MobileCLIP encoder to use. URIs take the form of {SCHEME}://{OPTIONAL_PATH} where {SCHEME} is one of s0,s1,s2 or blt and {OPTIONAL_PATH} is the path to a local directory containing compiled MobileCLIP CoreML model files. If {OPTIONAL_PATH} is empty then models will loaded from the application's default Bundle.")
    var encoder_uri: String = "s0://"
    
    @Option(help: "Enable verbose logging")
    var verbose: Bool = false
    
    @Argument(help: "The text to generate embeddings for. If \"-\" then data is read from STDIN. If the first argument is a valid path to a local file then the text of that file will be used. Otherwise all remaining arguments will be concatenated (with a space) and used as the text to generate embeddings for.")
    var args: [String]
    
    func run() async throws {
    }
}
