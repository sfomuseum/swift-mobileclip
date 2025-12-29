import CoreML
import Foundation

public struct BLTModel: CLIPEncoder {
    
    public let targetImageSize = CGSize(width: 224, height: 224)
    public let model = String("apple/mobileclip_blt")

    private var text_model: mobileclip_blt_text?
    private var image_model: mobileclip_blt_image?
    
    public init() throws  {
        
        do {
            text_model = try mobileclip_blt_text()
            image_model = try mobileclip_blt_image()
        } catch {
            throw error
        }
    }
    
    public func encode(image: CVPixelBuffer) async  -> Result<MLMultiArray, Error> {

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
