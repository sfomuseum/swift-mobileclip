import Foundation
import CoreML

public enum CLIPEncoderError: Error {
    case invalidURI
    case invalidScheme
    case missingModel
}

public protocol CLIPEncoder {
    var targetImageSize: CGSize { get }
    var model: String { get }
    func encode(image: CVPixelBuffer) async -> Result<MLMultiArray, Error>
    func encode(text: MLMultiArray) async -> Result<MLMultiArray, Error>
}

public func NewClipEncoder(uri: String) throws -> CLIPEncoder {
    
    guard let u = URL(string: uri) else {
        throw CLIPEncoderError.invalidURI
    }
    
    print("PATH \(u.path)")
    
    switch u.scheme {
    case "s0":
        return try S0Model()
    case "s1":
        return try S1Model()
    case "s2":
        return try S2Model(u.path)
    case "blt":
        return try BLTModel()
    default:
        throw CLIPEncoderError.invalidScheme
    }
}
