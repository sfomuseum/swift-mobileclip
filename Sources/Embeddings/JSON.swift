import Foundation
import MobileCLIP

func writeEmbeddingsAsJSON(results: MobileCLIP.Embeddings) throws -> Void {
    
    let encoder = JSONEncoder()
    encoder.outputFormatting = .sortedKeys
    
    do {
        let data = try encoder.encode(results)
        FileHandle.standardOutput.write(data)
    } catch {
        throw error
    }
}
