//
//  CIImage+Extension.swift
//  AppExhibit
//
//  Created by Jan Armbrust on 12/11/24.
//

import SwiftUI

extension CIImage {
  var transparent: CIImage? {
    return inverted?.blackTransparent
  }

  var inverted: CIImage? {
    guard let invertedColorFilter = CIFilter(name: "CIColorInvert") else { return nil }

    invertedColorFilter.setValue(self, forKey: "inputImage")
    return invertedColorFilter.outputImage
  }

  var blackTransparent: CIImage? {
    guard let blackTransparentFilter = CIFilter(name: "CIMaskToAlpha") else { return nil }
    blackTransparentFilter.setValue(self, forKey: "inputImage")
    return blackTransparentFilter.outputImage
  }

  func tinted(using color: UIColor) -> CIImage? {
    guard
      let transparentQRImage = transparent,
      let filter = CIFilter(name: "CIMultiplyCompositing"),
      let colorFilter = CIFilter(name: "CIConstantColorGenerator")
    else { return nil }

    let ciColor = CIColor(color: color)
    colorFilter.setValue(ciColor, forKey: kCIInputColorKey)
    let colorImage = colorFilter.outputImage

    filter.setValue(colorImage, forKey: kCIInputImageKey)
    filter.setValue(transparentQRImage, forKey: kCIInputBackgroundImageKey)

    return filter.outputImage!
  }

  func combined(with image: CIImage) -> CIImage? {
    guard let combinedFilter = CIFilter(name: "CISourceOverCompositing") else { return nil }
    let centerTransform = CGAffineTransform(
      translationX: extent.midX - (image.extent.size.width / 2), y: extent.midY - (image.extent.size.height / 2))
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

  func generateColorPalette(clusterCount: Int = 4) -> [UIColor] {
    // Step 1: Apply the CIKMeans filter
    let kMeansFilter = CIFilter(
      name: "CIKMeans",
      parameters: [
        kCIInputImageKey: self,
        "inputExtent": CIVector(cgRect: extent),
        "inputCount": clusterCount,
      ])

    guard let kMeansOutput = kMeansFilter?.outputImage else { return [] }

    // Step 2: Render the clusters to extract colors
    var kMeansBitmap = [UInt8](repeating: 0, count: clusterCount * 4)  // RGBA for each cluster
    let context = CIContext()
    context.render(
      kMeansOutput, toBitmap: &kMeansBitmap, rowBytes: clusterCount * 4,
      bounds: CGRect(x: 0, y: 0, width: clusterCount, height: 1), format: .RGBA8, colorSpace: nil)

    // Step 3: Convert clusters into a palette of UIColor
    var palette: [UIColor] = []
    for i in 0..<clusterCount {
      let r = CGFloat(kMeansBitmap[i * 4]) / 255.0
      let g = CGFloat(kMeansBitmap[i * 4 + 1]) / 255.0
      let b = CGFloat(kMeansBitmap[i * 4 + 2]) / 255.0
      let a = CGFloat(kMeansBitmap[i * 4 + 3]) / 255.0

      let color = UIColor(red: r, green: g, blue: b, alpha: a)
      palette.append(color)
    }

    return palette
  }

  func detectAccentColor(
      fromPalette palette: [UIColor],
      luminanceThreshold: CGFloat = 0.3,
      saturationThreshold: CGFloat = 0.2,
      isDarkMode: Bool = false
  ) -> UIColor? {
      var selectedColor: UIColor?
      var maxSaturation: CGFloat = 0

      for color in palette {
          var hue: CGFloat = 0
          var saturation: CGFloat = 0
          var brightness: CGFloat = 0
          color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: nil)

          // Skip neutral colors (low brightness or saturation)
          if brightness > luminanceThreshold && saturation > saturationThreshold {
              // Select the color with the highest saturation
              if saturation > maxSaturation {
                  maxSaturation = saturation
                  selectedColor = color
              }
          }
      }

      // Handle cases where no suitable color is found or a neutral color dominates
      if selectedColor == nil || isNeutralColor(selectedColor!) {
          // For dark mode, use white as the fallback; for light mode, use black
          return isDarkMode ? UIColor.white : UIColor.black
      }

      return selectedColor
  }

  // Helper function to check if a color is neutral (close to black, white, or gray)
  private func isNeutralColor(_ color: UIColor) -> Bool {
      var brightness: CGFloat = 0
      var saturation: CGFloat = 0
      color.getHue(nil, saturation: &saturation, brightness: &brightness, alpha: nil)

      // Neutral colors have low saturation and brightness close to 0 or 1
      return (brightness < 0.2 || brightness > 0.8) && saturation < 0.2
  }
}
