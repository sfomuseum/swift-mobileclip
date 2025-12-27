import CoreML
import Foundation

public struct BLTModel: CLIPEncoder {


    /*
    let imageEncoder = AsyncFactory {
        do {
            return try mobileclip_blt_image()
        } catch {
            fatalError("Failed to initialize ML model: \(error)")
        }
    }

    let textEncoder = AsyncFactory {
        do {
            return try mobileclip_blt_text()
        } catch {
            fatalError("Failed to initialize ML model: \(error)")
        }
    }

    func load() async {
        async let t = textEncoder.get()
        async let i = imageEncoder.get()
        _ = await (t, i)
    }
     */
    
    public let targetImageSize = CGSize(width: 224, height: 224)

    public func encode(image: CVPixelBuffer) async  -> Result<MLMultiArray, Error> {
        do {
            // let rsp = try await imageEncoder.get().prediction(image: image).final_emb_1
            let enc = try mobileclip_blt_image()
            let rsp = try enc.prediction(image: image).final_emb_1
            return .success(rsp)
        } catch {
            return .failure(error)
        }
    }

    public func encode(text: MLMultiArray) async  -> Result<MLMultiArray, Error> {
        do {
            // let rsp = try await textEncoder.get().prediction(text: text).final_emb_1
            let enc = try mobileclip_blt_text()
            let rsp = try enc.prediction(text: text).final_emb_1
            return .success(rsp)
        } catch {
            return .failure(error)
        }
    }
}
