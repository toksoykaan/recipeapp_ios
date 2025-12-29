import Foundation
import Vision
import UIKit

/// Service for extracting text from images using Apple's Vision framework
class VisionOCRService {
    static let shared = VisionOCRService()

    private init() {}

    /// Extract text from an image using Vision framework
    func extractText(from image: UIImage) async throws -> String {
        guard let cgImage = image.cgImage else {
            throw RecipeError.invalidResponse
        }

        return try await withCheckedThrowingContinuation { continuation in
            let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])

            let request = VNRecognizeTextRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(throwing: RecipeError.parsingError)
                    return
                }

                let recognizedStrings = observations.compactMap { observation in
                    observation.topCandidates(1).first?.string
                }

                let fullText = recognizedStrings.joined(separator: "\n")

                if fullText.isEmpty {
                    continuation.resume(throwing: RecipeError.parsingError)
                } else {
                    continuation.resume(returning: fullText)
                }
            }

            // Configure the request for better accuracy
            request.recognitionLevel = .accurate
            request.recognitionLanguages = ["en-US", "tr-TR"] // Support English and Turkish
            request.usesLanguageCorrection = true

            do {
                try requestHandler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    /// Preprocess image for better OCR results
    func preprocessImage(_ image: UIImage) -> UIImage {
        guard let ciImage = CIImage(image: image) else {
            return image
        }

        let context = CIContext()

        // Apply filters to enhance text recognition
        var processedImage = ciImage

        // Convert to grayscale
        if let grayscaleFilter = CIFilter(name: "CIPhotoEffectNoir") {
            grayscaleFilter.setValue(processedImage, forKey: kCIInputImageKey)
            if let output = grayscaleFilter.outputImage {
                processedImage = output
            }
        }

        // Enhance contrast
        if let contrastFilter = CIFilter(name: "CIColorControls") {
            contrastFilter.setValue(processedImage, forKey: kCIInputImageKey)
            contrastFilter.setValue(1.5, forKey: kCIInputContrastKey) // Increase contrast
            contrastFilter.setValue(0.0, forKey: kCIInputBrightnessKey)
            contrastFilter.setValue(1.0, forKey: kCIInputSaturationKey)
            if let output = contrastFilter.outputImage {
                processedImage = output
            }
        }

        // Sharpen the image
        if let sharpenFilter = CIFilter(name: "CISharpenLuminance") {
            sharpenFilter.setValue(processedImage, forKey: kCIInputImageKey)
            sharpenFilter.setValue(0.8, forKey: kCIInputSharpnessKey)
            if let output = sharpenFilter.outputImage {
                processedImage = output
            }
        }

        guard let cgImage = context.createCGImage(processedImage, from: processedImage.extent) else {
            return image
        }

        return UIImage(cgImage: cgImage)
    }
}
