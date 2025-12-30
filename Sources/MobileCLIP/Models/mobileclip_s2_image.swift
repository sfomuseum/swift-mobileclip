//
// mobileclip_s2_image.swift
//
// This file was automatically generated and should not be edited.
//

import CoreML


/// Model Prediction Input Type
@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
class mobileclip_s2_imageInput : MLFeatureProvider {

    /// Input image to be processed as color (kCVPixelFormatType_32BGRA) image buffer, 256 pixels wide by 256 pixels high
    var image: CVPixelBuffer

    var featureNames: Set<String> { ["image"] }

    func featureValue(for featureName: String) -> MLFeatureValue? {
        if featureName == "image" {
            return MLFeatureValue(pixelBuffer: image)
        }
        return nil
    }

    init(image: CVPixelBuffer) {
        self.image = image
    }

    convenience init(imageWith image: CGImage) throws {
        self.init(image: try MLFeatureValue(cgImage: image, pixelsWide: 256, pixelsHigh: 256, pixelFormatType: kCVPixelFormatType_32ARGB, options: nil).imageBufferValue!)
    }

    convenience init(imageAt image: URL) throws {
        self.init(image: try MLFeatureValue(imageAt: image, pixelsWide: 256, pixelsHigh: 256, pixelFormatType: kCVPixelFormatType_32ARGB, options: nil).imageBufferValue!)
    }

    func setImage(with image: CGImage) throws  {
        self.image = try MLFeatureValue(cgImage: image, pixelsWide: 256, pixelsHigh: 256, pixelFormatType: kCVPixelFormatType_32ARGB, options: nil).imageBufferValue!
    }

    func setImage(with image: URL) throws  {
        self.image = try MLFeatureValue(imageAt: image, pixelsWide: 256, pixelsHigh: 256, pixelFormatType: kCVPixelFormatType_32ARGB, options: nil).imageBufferValue!
    }

}


/// Model Prediction Output Type
@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
class mobileclip_s2_imageOutput : MLFeatureProvider {

    /// Source provided by CoreML
    private let provider : MLFeatureProvider

    /// the clip embedding of the input image as 1 by 512 matrix of floats
    var final_emb_1: MLMultiArray {
        provider.featureValue(for: "final_emb_1")!.multiArrayValue!
    }

    /// the clip embedding of the input image as 1 by 512 matrix of floats
    var final_emb_1ShapedArray: MLShapedArray<Float> {
        MLShapedArray<Float>(final_emb_1)
    }

    var featureNames: Set<String> {
        provider.featureNames
    }

    func featureValue(for featureName: String) -> MLFeatureValue? {
        provider.featureValue(for: featureName)
    }

    init(final_emb_1: MLMultiArray) {
        self.provider = try! MLDictionaryFeatureProvider(dictionary: ["final_emb_1" : MLFeatureValue(multiArray: final_emb_1)])
    }

    init(features: MLFeatureProvider) {
        self.provider = features
    }
}


/// Class for model loading and prediction
@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
class mobileclip_s2_image {
    let model: MLModel

    /// URL of model assuming it was installed in the same bundle as this class
    class var urlOfModelInThisBundle : URL {
        // let bundle = Bundle(for: self)
        // return bundle.url(forResource: "mobileclip_s2_image", withExtension:"mlmodelc")!

	let wtf = Bundle.module.url(forResource: "Resources/mobileclip_s2_image", withExtension:"mlmodelc")
	print("IMG \(wtf)")
        return Bundle.module.url(forResource: "mobileclip_s2_image", withExtension:"mlmodelc")!    
    }

    /**
        Construct mobileclip_s2_image instance with an existing MLModel object.

        Usually the application does not use this initializer unless it makes a subclass of mobileclip_s2_image.
        Such application may want to use `MLModel(contentsOfURL:configuration:)` and `mobileclip_s2_image.urlOfModelInThisBundle` to create a MLModel object to pass-in.

        - parameters:
          - model: MLModel object
    */
    init(model: MLModel) {
        self.model = model
    }

    /**
        Construct a model with configuration

        - parameters:
           - configuration: the desired model configuration

        - throws: an NSError object that describes the problem
    */
    convenience init(configuration: MLModelConfiguration = MLModelConfiguration()) throws {
        // try self.init(contentsOf: type(of:self).urlOfModelInThisBundle, configuration: configuration)

		guard let url = URL(string: "file:///Users/asc/sfomuseum/swift-mobileclip/Sources/Embeddings/Resources/mobileclip_s2_image.mlmodelc") else {
		      fatalError("SAD")
		      }

		      print("WOO")
        try self.init(contentsOf: url, configuration: configuration)	
    }

    /**
        Construct mobileclip_s2_image instance with explicit path to mlmodelc file
        - parameters:
           - modelURL: the file url of the model

        - throws: an NSError object that describes the problem
    */
    convenience init(contentsOf modelURL: URL) throws {
        try self.init(model: MLModel(contentsOf: modelURL))
    }

    /**
        Construct a model with URL of the .mlmodelc directory and configuration

        - parameters:
           - modelURL: the file url of the model
           - configuration: the desired model configuration

        - throws: an NSError object that describes the problem
    */
    convenience init(contentsOf modelURL: URL, configuration: MLModelConfiguration) throws {
        try self.init(model: MLModel(contentsOf: modelURL, configuration: configuration))
    }

    /**
        Construct mobileclip_s2_image instance asynchronously with optional configuration.

        Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.

        - parameters:
          - configuration: the desired model configuration
          - handler: the completion handler to be called when the model loading completes successfully or unsuccessfully
    */
    class func load(configuration: MLModelConfiguration = MLModelConfiguration(), completionHandler handler: @escaping (Swift.Result<mobileclip_s2_image, Error>) -> Void) {
        load(contentsOf: self.urlOfModelInThisBundle, configuration: configuration, completionHandler: handler)
    }

    /**
        Construct mobileclip_s2_image instance asynchronously with optional configuration.

        Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.

        - parameters:
          - configuration: the desired model configuration
    */
    class func load(configuration: MLModelConfiguration = MLModelConfiguration()) async throws -> mobileclip_s2_image {
        try await load(contentsOf: self.urlOfModelInThisBundle, configuration: configuration)
    }

    /**
        Construct mobileclip_s2_image instance asynchronously with URL of the .mlmodelc directory with optional configuration.

        Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.

        - parameters:
          - modelURL: the URL to the model
          - configuration: the desired model configuration
          - handler: the completion handler to be called when the model loading completes successfully or unsuccessfully
    */
    class func load(contentsOf modelURL: URL, configuration: MLModelConfiguration = MLModelConfiguration(), completionHandler handler: @escaping (Swift.Result<mobileclip_s2_image, Error>) -> Void) {
        MLModel.load(contentsOf: modelURL, configuration: configuration) { result in
            switch result {
            case .failure(let error):
                handler(.failure(error))
            case .success(let model):
                handler(.success(mobileclip_s2_image(model: model)))
            }
        }
    }

    /**
        Construct mobileclip_s2_image instance asynchronously with URL of the .mlmodelc directory with optional configuration.

        Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.

        - parameters:
          - modelURL: the URL to the model
          - configuration: the desired model configuration
    */
    class func load(contentsOf modelURL: URL, configuration: MLModelConfiguration = MLModelConfiguration()) async throws -> mobileclip_s2_image {
        let model = try await MLModel.load(contentsOf: modelURL, configuration: configuration)
        return mobileclip_s2_image(model: model)
    }

    /**
        Make a prediction using the structured interface

        It uses the default function if the model has multiple functions.

        - parameters:
           - input: the input to the prediction as mobileclip_s2_imageInput

        - throws: an NSError object that describes the problem

        - returns: the result of the prediction as mobileclip_s2_imageOutput
    */
    func prediction(input: mobileclip_s2_imageInput) throws -> mobileclip_s2_imageOutput {
        try prediction(input: input, options: MLPredictionOptions())
    }

    /**
        Make a prediction using the structured interface

        It uses the default function if the model has multiple functions.

        - parameters:
           - input: the input to the prediction as mobileclip_s2_imageInput
           - options: prediction options

        - throws: an NSError object that describes the problem

        - returns: the result of the prediction as mobileclip_s2_imageOutput
    */
    func prediction(input: mobileclip_s2_imageInput, options: MLPredictionOptions) throws -> mobileclip_s2_imageOutput {
        let outFeatures = try model.prediction(from: input, options: options)
        return mobileclip_s2_imageOutput(features: outFeatures)
    }

    /**
        Make an asynchronous prediction using the structured interface

        It uses the default function if the model has multiple functions.

        - parameters:
           - input: the input to the prediction as mobileclip_s2_imageInput
           - options: prediction options

        - throws: an NSError object that describes the problem

        - returns: the result of the prediction as mobileclip_s2_imageOutput
    */
    @available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
    func prediction(input: mobileclip_s2_imageInput, options: MLPredictionOptions = MLPredictionOptions()) async throws -> mobileclip_s2_imageOutput {
        let outFeatures = try await model.prediction(from: input, options: options)
        return mobileclip_s2_imageOutput(features: outFeatures)
    }

    /**
        Make a prediction using the convenience interface

        It uses the default function if the model has multiple functions.

        - parameters:
            - image: Input image to be processed as color (kCVPixelFormatType_32BGRA) image buffer, 256 pixels wide by 256 pixels high

        - throws: an NSError object that describes the problem

        - returns: the result of the prediction as mobileclip_s2_imageOutput
    */
    func prediction(image: CVPixelBuffer) throws -> mobileclip_s2_imageOutput {
        let input_ = mobileclip_s2_imageInput(image: image)
        return try prediction(input: input_)
    }

    /**
        Make a batch prediction using the structured interface

        It uses the default function if the model has multiple functions.

        - parameters:
           - inputs: the inputs to the prediction as [mobileclip_s2_imageInput]
           - options: prediction options

        - throws: an NSError object that describes the problem

        - returns: the result of the prediction as [mobileclip_s2_imageOutput]
    */
    func predictions(inputs: [mobileclip_s2_imageInput], options: MLPredictionOptions = MLPredictionOptions()) throws -> [mobileclip_s2_imageOutput] {
        let batchIn = MLArrayBatchProvider(array: inputs)
        let batchOut = try model.predictions(from: batchIn, options: options)
        var results : [mobileclip_s2_imageOutput] = []
        results.reserveCapacity(inputs.count)
        for i in 0..<batchOut.count {
            let outProvider = batchOut.features(at: i)
            let result =  mobileclip_s2_imageOutput(features: outProvider)
            results.append(result)
        }
        return results
    }
}
