import Foundation
import CoreML

// Compute Text Embeddings
public func ComputeTextEmbeddings(model: CLIPEncoder, tokenizer: CLIPTokenizer, promptArr: [String]) async -> [MLMultiArray] {
    var textEmbeddings: [MLMultiArray] = []
    do {
        for singlePrompt in promptArr {
            print("")
            print("Prompt text: \(singlePrompt)")

            // Tokenize the text query
            let inputIds =  tokenizer.encode_full(text: singlePrompt)

            // Convert [Int] to MultiArray
            let inputArray = try MLMultiArray(shape: [1, 77], dataType: .int32)
            for (index, element) in inputIds.enumerated() {
                inputArray[index] = NSNumber(value: element)
            }

            // Run the text model on the text query
            let rsp = await model.encode(text: inputArray)
            
            switch rsp {
            case .success(let output):
                textEmbeddings.append(output)
            case .failure(let error):
                throw error
            }
        }
    } catch {
        print(error.localizedDescription)
    }
    return textEmbeddings
}
