//
//  CIImage+Extension.swift
//  AppExhibit
//
//  Created by Jan Armbrust on 12/11/24.
//

import SwiftUI

extension CIImage {
    /// Inverts the colors and creates a transparent image by converting the mask to alpha.
    /// Input image should be black and white.
    var transparent: CIImage? {
        return inverted?.blackTransparent
    }

    /// Inverts the colors.
    var inverted: CIImage? {
        guard let invertedColorFilter = CIFilter(name: "CIColorInvert") else { return nil }

        invertedColorFilter.setValue(self, forKey: "inputImage")
        return invertedColorFilter.outputImage
    }

    /// Converts all black to transparent.
    var blackTransparent: CIImage? {
        guard let blackTransparentFilter = CIFilter(name: "CIMaskToAlpha") else { return nil }
        blackTransparentFilter.setValue(self, forKey: "inputImage")
        return blackTransparentFilter.outputImage
    }

    /// Applies the given color as a tint color.
    func tinted(using color: UIColor) -> CIImage?
    {
        guard
            let transparentQRImage = transparent,
            let filter = CIFilter(name: "CIMultiplyCompositing"),
            let colorFilter = CIFilter(name: "CIConstantColorGenerator") else { return nil }

        let ciColor = CIColor(color: color)
        colorFilter.setValue(ciColor, forKey: kCIInputColorKey)
        let colorImage = colorFilter.outputImage

        filter.setValue(colorImage, forKey: kCIInputImageKey)
        filter.setValue(transparentQRImage, forKey: kCIInputBackgroundImageKey)

        return filter.outputImage!
    }
  
  /// Combines the current image with the given image centered.
      func combined(with image: CIImage) -> CIImage? {
          guard let combinedFilter = CIFilter(name: "CISourceOverCompositing") else { return nil }
          let centerTransform = CGAffineTransform(translationX: extent.midX - (image.extent.size.width / 2), y: extent.midY - (image.extent.size.height / 2))
          combinedFilter.setValue(image.transformed(by: centerTransform), forKey: "inputImage")
          combinedFilter.setValue(self, forKey: "inputBackgroundImage")
          return combinedFilter.outputImage!
      }
  
  func maskedWithRoundedRectangle(cornerRadius: CGFloat) -> CIImage? {
          guard let roundedRectFilter = CIFilter(name: "CIRoundedRectangleGenerator") else { return nil }
          
          // Set up the rounded rectangle with the size of the image
          let rect = CGRect(origin: .zero, size: extent.size)
          roundedRectFilter.setValue(CIVector(cgRect: rect), forKey: "inputExtent")
          roundedRectFilter.setValue(cornerRadius, forKey: "inputRadius")
          
          guard let roundedRect = roundedRectFilter.outputImage else { return nil }
          
          // Blend the rounded rectangle mask with the logo image
          guard let blendFilter = CIFilter(name: "CIBlendWithAlphaMask") else { return nil }
          blendFilter.setValue(self, forKey: kCIInputImageKey)
          blendFilter.setValue(roundedRect, forKey: kCIInputMaskImageKey)
          
          return blendFilter.outputImage
      }
}
