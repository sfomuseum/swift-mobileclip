import CoreVideo
import CoreGraphics
import CoreImage
import ImageIO

enum CGImageError: Error {
    case notExists
    case sourceCreate
    case sourceCreateIndex
}

public func loadCGImage(at path: String) throws -> CGImage {
    let url = URL(fileURLWithPath: path)
    guard FileManager.default.fileExists(atPath: url.path) else {
        throw CGImageError.notExists
    }

    guard let source = CGImageSourceCreateWithURL(url as CFURL, nil) else {
        throw CGImageError.sourceCreate
    }

    // Optionally down‑sample large images:
    let options: [NSString: Any] = [
        kCGImageSourceShouldCache: false,
        // kCGImageSourceCreateThumbnailFromImageAlways: true,
        // kCGImageSourceThumbnailMaxPixelSize: 1024   // adjust as needed
    ]

    guard let im = CGImageSourceCreateImageAtIndex(source, 0, options as CFDictionary) else {
        throw CGImageError.sourceCreateIndex
    }
    
    return im
}

func render(
    cgImage: CGImage,
    into pixelBuffer: CVPixelBuffer,
    colorSpace: CGColorSpace? = nil,
    interpolationQuality: CGInterpolationQuality = .high
) -> Bool {

    guard kCVReturnSuccess == CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly) else {
        return false
    }
    defer { CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly) }

    let width  = CVPixelBufferGetWidth(pixelBuffer)
    let height = CVPixelBufferGetHeight(pixelBuffer)
    let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)

    guard let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer) else {
        return false
    }

    let cs = colorSpace ?? cgImage.colorSpace ?? CGColorSpaceCreateDeviceRGB()

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

    ctx.interpolationQuality = interpolationQuality

    let destRect = CGRect(x: 0, y: 0, width: width, height: height)
    ctx.draw(cgImage, in: destRect)

    return true
}
