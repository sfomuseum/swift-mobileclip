//
// mobileclip_blt_text.swift
//
// This file was automatically generated and should not be edited.
//

import CoreML


/// Model Prediction Input Type
@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
class mobileclip_blt_textInput : MLFeatureProvider {

    /// Input text already tokenized as 1 by 77 matrix of 32-bit integers
    var text: MLMultiArray

    var featureNames: Set<String> { ["text"] }

    func featureValue(for featureName: String) -> MLFeatureValue? {
        if featureName == "text" {
            return MLFeatureValue(multiArray: text)
        }
        return nil
    }

    init(text: MLMultiArray) {
        self.text = text
    }

    convenience init(text: MLShapedArray<Int32>) {
        self.init(text: MLMultiArray(text))
    }

}


/// Model Prediction Output Type
@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
class mobileclip_blt_textOutput : MLFeatureProvider {

    /// Source provided by CoreML
    private let provider : MLFeatureProvider

    /// the clip embedding of the input text as 1 by 512 matrix of floats
    var final_emb_1: MLMultiArray {
        provider.featureValue(for: "final_emb_1")!.multiArrayValue!
    }

    /// the clip embedding of the input text as 1 by 512 matrix of floats
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
class mobileclip_blt_text {
    let model: MLModel

    /// URL of model assuming it was installed in the same bundle as this class
    class var urlOfModelInThisBundle : URL {
        let bundle = Bundle(for: self)
        return bundle.url(forResource: "mobileclip_blt_text", withExtension:"mlmodelc")!
    }

    /**
        Construct mobileclip_blt_text instance with an existing MLModel object.

        Usually the application does not use this initializer unless it makes a subclass of mobileclip_blt_text.
        Such application may want to use `MLModel(contentsOfURL:configuration:)` and `mobileclip_blt_text.urlOfModelInThisBundle` to create a MLModel object to pass-in.

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
        try self.init(contentsOf: type(of:self).urlOfModelInThisBundle, configuration: configuration)
    }

    /**
        Construct mobileclip_blt_text instance with explicit path to mlmodelc file
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
        Construct mobileclip_blt_text instance asynchronously with optional configuration.

        Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.

        - parameters:
          - configuration: the desired model configuration
          - handler: the completion handler to be called when the model loading completes successfully or unsuccessfully
    */
    class func load(configuration: MLModelConfiguration = MLModelConfiguration(), completionHandler handler: @escaping (Swift.Result<mobileclip_blt_text, Error>) -> Void) {
        load(contentsOf: self.urlOfModelInThisBundle, configuration: configuration, completionHandler: handler)
    }

    /**
        Construct mobileclip_blt_text instance asynchronously with optional configuration.

        Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.

        - parameters:
          - configuration: the desired model configuration
    */
    class func load(configuration: MLModelConfiguration = MLModelConfiguration()) async throws -> mobileclip_blt_text {
        try await load(contentsOf: self.urlOfModelInThisBundle, configuration: configuration)
    }

    /**
        Construct mobileclip_blt_text instance asynchronously with URL of the .mlmodelc directory with optional configuration.

        Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.

        - parameters:
          - modelURL: the URL to the model
          - configuration: the desired model configuration
          - handler: the completion handler to be called when the model loading completes successfully or unsuccessfully
    */
    class func load(contentsOf modelURL: URL, configuration: MLModelConfiguration = MLModelConfiguration(), completionHandler handler: @escaping (Swift.Result<mobileclip_blt_text, Error>) -> Void) {
        MLModel.load(contentsOf: modelURL, configuration: configuration) { result in
            switch result {
            case .failure(let error):
                handler(.failure(error))
            case .success(let model):
                handler(.success(mobileclip_blt_text(model: model)))
            }
        }
    }

    /**
        Construct mobileclip_blt_text instance asynchronously with URL of the .mlmodelc directory with optional configuration.

        Model loading may take time when the model content is not immediately available (e.g. encrypted model). Use this factory method especially when the caller is on the main thread.

        - parameters:
          - modelURL: the URL to the model
          - configuration: the desired model configuration
    */
    class func load(contentsOf modelURL: URL, configuration: MLModelConfiguration = MLModelConfiguration()) async throws -> mobileclip_blt_text {
        let model = try await MLModel.load(contentsOf: modelURL, configuration: configuration)
        return mobileclip_blt_text(model: model)
    }

    /**
        Make a prediction using the structured interface

        It uses the default function if the model has multiple functions.

        - parameters:
           - input: the input to the prediction as mobileclip_blt_textInput

        - throws: an NSError object that describes the problem

        - returns: the result of the prediction as mobileclip_blt_textOutput
    */
    func prediction(input: mobileclip_blt_textInput) throws -> mobileclip_blt_textOutput {
        try prediction(input: input, options: MLPredictionOptions())
    }

    /**
        Make a prediction using the structured interface

        It uses the default function if the model has multiple functions.

        - parameters:
           - input: the input to the prediction as mobileclip_blt_textInput
           - options: prediction options

        - throws: an NSError object that describes the problem

        - returns: the result of the prediction as mobileclip_blt_textOutput
    */
    func prediction(input: mobileclip_blt_textInput, options: MLPredictionOptions) throws -> mobileclip_blt_textOutput {
        let outFeatures = try model.prediction(from: input, options: options)
        return mobileclip_blt_textOutput(features: outFeatures)
    }

    /**
        Make an asynchronous prediction using the structured interface

        It uses the default function if the model has multiple functions.

        - parameters:
           - input: the input to the prediction as mobileclip_blt_textInput
           - options: prediction options

        - throws: an NSError object that describes the problem

        - returns: the result of the prediction as mobileclip_blt_textOutput
    */
    @available(macOS 14.0, iOS 17.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
    func prediction(input: mobileclip_blt_textInput, options: MLPredictionOptions = MLPredictionOptions()) async throws -> mobileclip_blt_textOutput {
        let outFeatures = try await model.prediction(from: input, options: options)
        return mobileclip_blt_textOutput(features: outFeatures)
    }

    /**
        Make a prediction using the convenience interface

        It uses the default function if the model has multiple functions.

        - parameters:
            - text: Input text already tokenized as 1 by 77 matrix of 32-bit integers

        - throws: an NSError object that describes the problem

        - returns: the result of the prediction as mobileclip_blt_textOutput
    */
    func prediction(text: MLMultiArray) throws -> mobileclip_blt_textOutput {
        let input_ = mobileclip_blt_textInput(text: text)
        return try prediction(input: input_)
    }

    /**
        Make a prediction using the convenience interface

        It uses the default function if the model has multiple functions.

        - parameters:
            - text: Input text already tokenized as 1 by 77 matrix of 32-bit integers

        - throws: an NSError object that describes the problem

        - returns: the result of the prediction as mobileclip_blt_textOutput
    */

    func prediction(text: MLShapedArray<Int32>) throws -> mobileclip_blt_textOutput {
        let input_ = mobileclip_blt_textInput(text: text)
        return try prediction(input: input_)
    }

    /**
        Make a batch prediction using the structured interface

        It uses the default function if the model has multiple functions.

        - parameters:
           - inputs: the inputs to the prediction as [mobileclip_blt_textInput]
           - options: prediction options

        - throws: an NSError object that describes the problem

        - returns: the result of the prediction as [mobileclip_blt_textOutput]
    */
    func predictions(inputs: [mobileclip_blt_textInput], options: MLPredictionOptions = MLPredictionOptions()) throws -> [mobileclip_blt_textOutput] {
        let batchIn = MLArrayBatchProvider(array: inputs)
        let batchOut = try model.predictions(from: batchIn, options: options)
        var results : [mobileclip_blt_textOutput] = []
        results.reserveCapacity(inputs.count)
        for i in 0..<batchOut.count {
            let outProvider = batchOut.features(at: i)
            let result =  mobileclip_blt_textOutput(features: outProvider)
            results.append(result)
        }
        return results
    }
}
