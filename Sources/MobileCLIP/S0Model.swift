import CoreML
import Foundation

public struct S0Model: CLIPEncoder {
    
    public let targetImageSize = CGSize(width: 256, height: 256)
    
    private var text_model: mobileclip_s0_text?
    private var image_model: mobileclip_s0_image?
    
    public init() throws  {
        
        do {
            text_model = try mobileclip_s0_text()
            image_model = try mobileclip_s0_image()
        } catch {
            throw error
        }
    }
    
    public func encode(image: CVPixelBuffer) async -> Result<MLMultiArray, Error> {
        do {
            
            guard let model = self.image_model else {
                throw CLIPEncoderError.missingModel
            }
            
            let rsp = try model.prediction(image: image).final_emb_1
            return .success(rsp)
        } catch {
            return .failure(error)
        }
    }
    
    public func encode(text: MLMultiArray) async  -> Result<MLMultiArray, Error> {
        do {
            
            guard let model = self.text_model else {
                throw CLIPEncoderError.missingModel
            }
            
            let rsp = try model.prediction(text: text).final_emb_1
            return .success(rsp)
        } catch {
            return .failure(error)
        }
    }
}
