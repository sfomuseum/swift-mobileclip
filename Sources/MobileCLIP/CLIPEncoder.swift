import Foundation
import CoreML

public enum CLIPEncoderError: Error, LocalizedError {
    case invalidURI
    case invalidComponents
    case invalidScheme
    case missingModel
    
    public var errorDescription: String? {
        switch self {
        case .invalidURI:
            return "Failed to parse URI."
        case .invalidComponents:
            return "Failed to derive components from URI."
        case .invalidScheme:
            return "Invalid or unsupported URI scheme."
        case .missingModel:
            return "Failed to load model, not found."
        }
    }
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
        
    var models: URL?
    
    if u.path != "" {

        guard let m = URL(string: u.path) else {
            throw CLIPEncoderError.invalidURI
        }
        
        models = m
    }
    
    switch u.scheme {
    case "s0":
        return try S0Model(models)
    case "s1":
        return try S1Model(models)
    case "s2":
        return try S2Model(models)
    case "blt":
        return try BLTModel(models)
    default:
        throw CLIPEncoderError.invalidScheme
    }
}
