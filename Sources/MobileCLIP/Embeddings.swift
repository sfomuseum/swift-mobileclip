import CoreML
import Foundation

public enum EmbeddingsErrors: Error {
    case pixelBufferError
    case imageRenderError
}

public struct Embeddings: Codable {
    var embeddings: [Double] 
    var dimensions: Int
    var model: String
    var created: Int64

}

private func newEmbeddings(encoder: CLIPEncoder, mlMultiArray: MLMultiArray) -> Embeddings {
    
    let ts = Int64(Date().timeIntervalSince1970)
    
    let emb = Embeddings(
        embeddings: convertToArray(from: mlMultiArray),
        dimensions: Int(truncating: mlMultiArray.shape[1]),
        model: encoder.model,
        created: ts
    )
    
    return emb
}

private func convertToArray(from mlMultiArray: MLMultiArray) -> [Double] {
    
    // Init our output array
    var array: [Double] = []
    
    // Get length
    let length = mlMultiArray.count
    
    // Set content of multi array to our out put array
    for i in 0...length - 1 {
        array.append(Double(truncating: mlMultiArray[[0,NSNumber(value: i)]]))
    }
    
    return array
}

public func ComputeTextEmbeddings(encoder: CLIPEncoder, tokenizer: CLIPTokenizer, text: String) async -> Result<Embeddings, Error>  {

    do {
        // Tokenize the text query
        let inputIds =  tokenizer.encode_full(text: text)
        
        // Convert [Int] to MultiArray
        let inputArray = try MLMultiArray(shape: [1, 77], dataType: .int32)
        for (index, element) in inputIds.enumerated() {
            inputArray[index] = NSNumber(value: element)
        }
        
        // Run the text model on the text query
        let rsp = await encoder.encode(text: inputArray)
        
        switch rsp {
        case .success(let output):
            let emb = newEmbeddings(encoder: encoder, mlMultiArray: output)
            return .success(emb)
        case .failure(let error):
            return .failure(error)
        }
    } catch {
        return .failure(error)
    }
}

public func ComputeImageEmbeddings(encoder: CLIPEncoder, image: CGImage) async -> Result<Embeddings, Error> {
    
    print("COMPUTE 1")
    let im = cgImageResizePreservingAspectRatio(image, toFit: encoder.targetImageSize)!
    
    print("COMPUTE 2")
    
    let extent = CGRect(x: 0,
                        y: 0,
                        width: im.width,
                        height: im.height)

    
    let pixelFormat = kCVPixelFormatType_32ARGB
    var output: CVPixelBuffer?
    
    CVPixelBufferCreate(nil, Int(extent.width), Int(extent.height), pixelFormat, nil, &output)

    print("COMPUTE 3")
    guard let output else {
        return .failure(EmbeddingsErrors.pixelBufferError)
    }
    
    print("COMPUTE 4")
    if !render(cgImage: im, into: output) {
        return .failure(EmbeddingsErrors.imageRenderError)
    }

    print("GO")
    let rsp = await encoder.encode(image: output)
    
    switch rsp {
    case .success(let output):
        
        let emb = newEmbeddings(encoder: encoder, mlMultiArray: output)
        return .success(emb)
    case .failure(let error):
        return .failure(error)
    }

}
