import Foundation
import CoreML

public enum CLIPEncoderError: Error {
    case invalidURI
    case invalidScheme
    case missingModel
}

public protocol CLIPEncoder {
    var targetImageSize: CGSize { get }
    // mutating func load() throws -> Void
    func encode(image: CVPixelBuffer) async -> Result<MLMultiArray, Error>
    func encode(text: MLMultiArray) async -> Result<MLMultiArray, Error>
}

public func NewClipEncoder(uri: String) throws -> CLIPEncoder {
    
    guard let u = URL(string: uri) else {
        throw CLIPEncoderError.invalidURI
    }
    
    switch u.scheme {
    case "s0":
        return try S0Model()
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
