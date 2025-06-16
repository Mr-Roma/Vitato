//
//  TattooSelectionViewModel.swift
//  TatoAnchor
//
//  Created by Romario Marcal on 14/06/25.
//

// TattooSelectionViewModel.swift
import SwiftUI
import PhotosUI
import Vision
import CoreImage.CIFilterBuiltins

class TattooSelectionViewModel: ObservableObject {
    @Published var selectedTattoo: UIImage?
    @Published var showImagePicker = false
    @Published var showCamera = false
    @Published var selectedItem: PhotosPickerItem?
    @Published var isProcessingImage = false
    
    let recommendedTattoos = [
        "tattoo1", "tattoo2", "tattoo3", "tattoo4"
    ].compactMap { UIImage(named: $0) }
    
    private var processingQueue = DispatchQueue(label: "ProcessingQueue")
    
    func removeBackground(from image: UIImage, completion: @escaping (UIImage?) -> Void) {
        isProcessingImage = true
        processingQueue.async {
            guard let inputImage = CIImage(image: image) else {
                DispatchQueue.main.async {
                    completion(nil)
                    self.isProcessingImage = false
                }
                return
            }
            
            // Generate foreground mask
            guard let maskImage = self.generateForegroundMask(from: inputImage) else {
                DispatchQueue.main.async {
                    completion(nil)
                    self.isProcessingImage = false
                }
                return
            }
            
            // Apply mask to original image
            let outputImage = self.apply(mask: maskImage, to: inputImage)
            let resultImage = self.render(ciImage: outputImage)
            
            DispatchQueue.main.async {
                completion(resultImage)
                self.isProcessingImage = false
            }
        }
    }
    
    private func generateForegroundMask(from inputImage: CIImage) -> CIImage? {
        let handler = VNImageRequestHandler(ciImage: inputImage)
        let request = VNGenerateForegroundInstanceMaskRequest()
        
        do {
            try handler.perform([request])
        } catch {
            print("Failed to perform mask request: \(error)")
            return nil
        }
        
        guard let result = request.results?.first else {
            print("No observations found")
            return nil
        }
        
        do {
            let maskPixelBuffer = try result.generateScaledMaskForImage(forInstances: result.allInstances, from: handler)
            return CIImage(cvPixelBuffer: maskPixelBuffer)
        } catch {
            print("Failed to generate mask: \(error)")
            return nil
        }
    }
    
    private func apply(mask: CIImage, to image: CIImage) -> CIImage {
        let filter = CIFilter.blendWithMask()
        filter.inputImage = image
        filter.maskImage = mask
        filter.backgroundImage = CIImage.empty()
        return filter.outputImage ?? image
    }
    
    private func render(ciImage: CIImage) -> UIImage {
        let context = CIContext(options: nil)
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            return UIImage(ciImage: ciImage)
        }
        return UIImage(cgImage: cgImage)
    }
}
