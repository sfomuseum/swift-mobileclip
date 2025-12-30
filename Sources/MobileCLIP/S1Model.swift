import CoreML
import Foundation

public struct S1Model: CLIPEncoder {

    public let targetImageSize = CGSize(width: 256, height: 256)
    public let model = String("apple/mobileclip_s1")

    private var text_model: mobileclip_s1_text?
    private var image_model: mobileclip_s1_image?
    
    public init(_ models: URL? = nil) throws  {
        
        do {
            
            if models != nil {
                
                guard var components = URLComponents(url: models!, resolvingAgainstBaseURL: true) else {
                    throw CLIPEncoderError.invalidComponents
                }
                
                components.scheme = "file"

                guard var im_url = components.url else {
                    throw CLIPEncoderError.invalidURI
                }
                
                guard var txt_url = components.url else {
                    throw CLIPEncoderError.invalidURI
                }
                
                im_url.append(path: "mobileclip_s1_image.mlmodelc")
                txt_url.append(path: "mobileclip_s1_text.mlmodelc")
                
                image_model = try mobileclip_s1_image(contentsOf: im_url)
                text_model = try mobileclip_s1_text(contentsOf: txt_url)
                
            } else {
                
                text_model = try mobileclip_s1_text()
                image_model = try mobileclip_s1_image()
            }
            
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


