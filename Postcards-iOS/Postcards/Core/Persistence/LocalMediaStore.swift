import Foundation

#if canImport(UIKit)
import UIKit
typealias StoredPlatformImage = UIImage
#elseif canImport(AppKit)
import AppKit
typealias StoredPlatformImage = NSImage
#endif

enum LocalMediaStore {
    private static let directoryName = "PostcardsMedia"

    static func save(images: [StoredPlatformImage]) throws -> [String] {
        let directoryURL = try mediaDirectoryURL()

        return try images.map { image in
            let filename = "\(UUID().uuidString).jpg"
            let fileURL = directoryURL.appendingPathComponent(filename)
            let data = try imageData(for: image)
            try data.write(to: fileURL, options: .atomic)
            return fileURL.path
        }
    }

    static func loadImage(from path: String) -> StoredPlatformImage? {
        let fileURL = URL(fileURLWithPath: path)
        guard let data = try? Data(contentsOf: fileURL) else {
            return nil
        }
        return platformImage(from: data)
    }

    private static func mediaDirectoryURL() throws -> URL {
        let rootURL = try FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        let directoryURL = rootURL.appendingPathComponent(directoryName, isDirectory: true)
        try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        return directoryURL
    }

    private static func imageData(for image: StoredPlatformImage) throws -> Data {
        guard let data = platformJPEGData(from: image) else {
            throw CocoaError(.fileWriteUnknown)
        }
        return data
    }

    private static func platformImage(from data: Data) -> StoredPlatformImage? {
#if canImport(UIKit)
        UIImage(data: data)
#elseif canImport(AppKit)
        NSImage(data: data)
#endif
    }

    private static func platformJPEGData(from image: StoredPlatformImage) -> Data? {
#if canImport(UIKit)
        image.jpegData(compressionQuality: 0.85) ?? image.pngData()
#elseif canImport(AppKit)
        guard
            let tiffData = image.tiffRepresentation,
            let bitmap = NSBitmapImageRep(data: tiffData)
        else {
            return nil
        }
        return bitmap.representation(using: .jpeg, properties: [.compressionFactor: 0.85])
            ?? bitmap.representation(using: .png, properties: [:])
#endif
    }
}
