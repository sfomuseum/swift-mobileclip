import Foundation
import CoreML

// Compute Image Embeddings
func computeImageEmbeddings(model: CLIPEncoder, frame: CVPixelBuffer) async throws -> MLMultiArray {
    // prepare the image
    var image: CGImage
    
    do {
        image = try cgImage(from: frame)
    } catch {
        throw error
    }
    
    image = drawSquareFromImage(image)!
    
    image = cgImageResizePreservingAspectRatio(image, toFit: model.targetImageSize)!
    
    let extent = CGRect(x: 0,
                        y: 0,
                        width: image.width,
                        height: image.height)

    
    let pixelFormat = kCVPixelFormatType_32ARGB
    var output: CVPixelBuffer?
    CVPixelBufferCreate(nil, Int(extent.width), Int(extent.height), pixelFormat, nil, &output)

    guard let output else {
        print("failed to create output CVPixelBuffer")
        fatalError("SAD")
    }
    
    render(cgImage: image, into: output)

    let rsp = await model.encode(image: output)
    
    switch rsp {
    case .success(let output):
        return output
    case .failure(let error):
        throw error
    }

}


/// Render a `CGImage` into a `CVPixelBuffer`.
///
/// - Parameters:
///   - image:  The source `CGImage` to draw.
///   - pixelBuffer: The destination `CVPixelBuffer`.
///                  It **must** be in a pixel format that matches the image
///                  (commonly `.bgra` – `kCVPixelFormatType_32BGRA`).
///   - colorSpace: Optional color space for the drawing.
///                 If `nil`, the image’s color space is used, or sRGB if that is missing.
///   - interpolationQuality: How the image should be scaled (default .high).
/// - Returns: `true` on success, `false` on any failure.
func render(
    cgImage: CGImage,
    into pixelBuffer: CVPixelBuffer,
    colorSpace: CGColorSpace? = nil,
    interpolationQuality: CGInterpolationQuality = .high
) -> Bool {

    // 1️⃣ Lock the buffer for writing
    guard kCVReturnSuccess == CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly) else {
        return false
    }
    defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly) }

    // 2️⃣ Gather buffer info
    let width  = CVPixelBufferGetWidth(pixelBuffer)
    let height = CVPixelBufferGetHeight(pixelBuffer)
    let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)

    guard let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer) else {
        return false
    }

    // 3️⃣ Determine the color space to use
    let cs = colorSpace ?? cgImage.colorSpace ?? CGColorSpaceCreateDeviceRGB()

    // 4️⃣ Create a CGContext that writes directly into the pixel buffer
    guard let ctx = CGContext(
        data: baseAddress,
        width: width,
        height: height,
        bitsPerComponent: 8,
        bytesPerRow: bytesPerRow,
        space: cs,
        bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue
    ) else {
        return false
    }

    // 5️⃣ Set interpolation quality
    ctx.interpolationQuality = interpolationQuality

    // 6️⃣ Draw the image – CoreGraphics will scale it to fill the buffer
    let destRect = CGRect(x: 0, y: 0, width: width, height: height)
    ctx.draw(cgImage, in: destRect)

    return true
}
