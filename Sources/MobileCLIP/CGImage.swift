import CoreVideo
import CoreGraphics
import CoreImage
import ImageIO

enum PixelBufferConversionError: Error, LocalizedError {
    case lockFailed
    case baseAddressNil
    case colorSpaceMissing
    case dataProviderFailed
    case cgImageCreationFailed
    case unsupportedFormat

    var errorDescription: String? {
        switch self {
        case .lockFailed:
            return "Failed to lock the CVPixelBuffer for reading."
        case .baseAddressNil:
            return "The pixel buffer has no base address."
        case .colorSpaceMissing:
            return "Unable to create the sRGB color space."
        case .dataProviderFailed:
            return "Failed to create a CGDataProvider from the pixel buffer."
        case .cgImageCreationFailed:
            return "Core Graphics failed to create a CGImage."
        case .unsupportedFormat:
            return "This pixel buffer format is not supported by the helper."
        }
    }
}

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


/// Convert a CVPixelBuffer into a CGImage.
///
/// - Parameter pixelBuffer: The source pixel buffer (must be locked before calling).
/// - Returns: A `CGImage` that represents the buffer’s contents.
/// - Throws: `PixelBufferConversionError` if the format is unsupported or
///           the conversion fails.
func cgImage(from pixelBuffer: CVPixelBuffer) throws -> CGImage {
    // 1️⃣ Lock the pixel buffer so we can read its data
    guard kCVReturnSuccess == CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly) else {
        throw PixelBufferConversionError.lockFailed
    }
    defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly) }

    // 2️⃣ Common image data
    let width  = CVPixelBufferGetWidth(pixelBuffer)
    let height = CVPixelBufferGetHeight(pixelBuffer)

    // 3️⃣ Handle the most common pixel formats
    let format = CVPixelBufferGetPixelFormatType(pixelBuffer)

    switch format {
    // ────────────────────────────────────────────────────────────────
    // 3A. 32‑bit BGRA (kCVPixelFormatType_32BGRA)
    case kCVPixelFormatType_32BGRA:
        // 3A‑1. Get the raw bytes
        guard let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer) else {
            throw PixelBufferConversionError.baseAddressNil
        }
        // 3A‑2. Bytes per row (includes padding)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)

        // 3A‑3. Color space (BGRA is equivalent to sRGB)
        guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) else {
            throw PixelBufferConversionError.colorSpaceMissing
        }

        // 3A‑4. Create the CGImage directly from the bytes
        guard let provider = CGDataProvider(dataInfo: nil,
                                            data: baseAddress,
                                            size: bytesPerRow * height,
                                            releaseData: { (_, _, _) in }) else {
            throw PixelBufferConversionError.dataProviderFailed
        }

        let bitmapInfo = CGBitmapInfo(rawValue:
            CGImageAlphaInfo.premultipliedFirst.rawValue | // BGRA
            CGImageByteOrderInfo.orderDefault.rawValue)    // Native order

        guard let cgImage = CGImage(width: width,
                                    height: height,
                                    bitsPerComponent: 8,
                                    bitsPerPixel: 32,
                                    bytesPerRow: bytesPerRow,
                                    space: colorSpace,
                                    bitmapInfo: bitmapInfo,
                                    provider: provider,
                                    decode: nil,
                                    shouldInterpolate: true,
                                    intent: .defaultIntent) else {
            throw PixelBufferConversionError.cgImageCreationFailed
        }

        return cgImage

    // ────────────────────────────────────────────────────────────────
    // 3B. 8‑bit YCbCr (kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)
    case kCVPixelFormatType_420YpCbCr8BiPlanarFullRange:
        // 3B‑1. Convert using Core Image – this handles the YCbCr → RGB conversion.
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext(options: [.workingColorSpace: NSNull()]) // No color space conversion
        guard let cgImage = context.createCGImage(ciImage,
                                                  from: CGRect(x: 0,
                                                               y: 0,
                                                               width: width,
                                                               height: height)) else {
            throw PixelBufferConversionError.cgImageCreationFailed
        }
        return cgImage

    // ────────────────────────────────────────────────────────────────
    default:
        throw PixelBufferConversionError.unsupportedFormat
    }
}

func drawSquareFromImage(_ src: CGImage) -> CGImage? {
    let side = min(src.width, src.height)
    let squareRect = CGRect(x: 0, y: 0, width: side, height: side)

    guard let ctx = CGContext(data: nil,
                              width: side,
                              height: side,
                              bitsPerComponent: src.bitsPerComponent,
                              bytesPerRow: 0,
                              space: src.colorSpace ?? CGColorSpaceCreateDeviceRGB(),
                              bitmapInfo: src.bitmapInfo.rawValue) else { return nil }

    // Clip to the square (here it’s the same as the context size)
    ctx.clip(to: squareRect)

    // Compute the source rect to center the image
    let srcOriginX = (src.width  - side) / 2
    let srcOriginY = (src.height - side) / 2
    let srcRect = CGRect(x: srcOriginX, y: srcOriginY, width: side, height: side)

    ctx.draw(src, in: squareRect, byTiling: false)
    return ctx.makeImage()
}

func cgImageResizePreservingAspectRatio(
    _ src: CGImage,
    toFit maxSize: CGSize,
    interpolationQuality: CGInterpolationQuality = .high
) -> CGImage? {
    let srcSize = CGSize(width: src.width, height: src.height)

    // Calculate scale factor
    let widthScale  = maxSize.width  / srcSize.width
    let heightScale = maxSize.height / srcSize.height
    let scale = min(widthScale, heightScale, 1.0)   // never upscale

    // Compute the target size
    let targetSize = CGSize(width: srcSize.width * scale,
                            height: srcSize.height * scale)

    return cgImageResize(src, to: targetSize, interpolationQuality: interpolationQuality)
}

/// Return a new `CGImage` that is a scaled‑down/up version of `src`.
///
/// - Parameters:
///   - src: The source image.
///   - targetSize: The size (in points) you want the output image to be.
///   - interpolationQuality: The quality of the scaling (default: `.high`).
/// - Returns: A new `CGImage` that is the resized version of `src`,
///            or `nil` if the context could not be created.
func cgImageResize(
    _ src: CGImage,
    to targetSize: CGSize,
    interpolationQuality: CGInterpolationQuality = .high
) -> CGImage? {
    // 1️⃣ Create a context that matches the target size
    let width  = Int(targetSize.width)
    let height = Int(targetSize.height)

    let colorSpace = CGColorSpaceCreateDeviceRGB()

    // Preserve the bitmapInfo of the source (alpha, order, etc.)
    let bitmapInfo = src.bitmapInfo

    guard let ctx = CGContext(
        data: nil,
        width: width,
        height: height,
        bitsPerComponent: src.bitsPerComponent,
        bytesPerRow: 0,               // let the system compute this
        space: colorSpace,
        bitmapInfo: bitmapInfo.rawValue
    ) else { return nil }

    // 2️⃣ Tell the context what quality to use for interpolation
    ctx.interpolationQuality = interpolationQuality

    // 3️⃣ Draw the source image into the target rect – the image is scaled automatically
    ctx.draw(src, in: CGRect(origin: .zero, size: targetSize))

    // 4️⃣ Grab the new CGImage from the context
    return ctx.makeImage()
}



public func loadCGImage(at path: String) -> CGImage? {
    let url = URL(fileURLWithPath: path)
    guard FileManager.default.fileExists(atPath: url.path) else { return nil }

    guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else { return nil }

    // Optionally down‑sample large images:
    let options: [NSString: Any] = [
        kCGImageSourceShouldCache: false,
        kCGImageSourceCreateThumbnailFromImageAlways: true,
        kCGImageSourceThumbnailMaxPixelSize: 1024   // adjust as needed
    ]

    return CGImageSourceCreateImageAtIndex(source, 0, options as CFDictionary)
}
