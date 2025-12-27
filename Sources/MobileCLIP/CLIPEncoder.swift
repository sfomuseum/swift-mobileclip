import Foundation
import CoreML

public enum CLIPEncoderError: Error {
    case invalidURI
    case invalidScheme
}

public protocol CLIPEncoder {
    var targetImageSize: CGSize { get }
    // func load() async
    func encode(image: CVPixelBuffer) async -> Result<MLMultiArray, Error>
    func encode(text: MLMultiArray) async -> Result<MLMultiArray, Error>
}

public func NewClipEncoder(uri: String) throws -> CLIPEncoder {
    
    guard let u = URL(string: uri) else {
        throw CLIPEncoderError.invalidURI
    }
    
    switch u.scheme {
    case "s0":
        return S0Model()
    case "s1":
        return S1Model()
    case "s2":
        return S2Model()
    case "blt":
        return BLTModel()
    default:
        throw CLIPEncoderError.invalidScheme
    }
}
