//
//  URL+Extension.swift
//  AppExhibit
//
//  Created by Jan Armbrust on 12/11/24.
//

import SwiftUI

extension URL {
  var qrImage: CIImage? {
    guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
    let qrData = absoluteString.data(using: String.Encoding.ascii)
    qrFilter.setValue(qrData, forKey: "inputMessage")
    let qrTransform = CGAffineTransform(scaleX: 12, y: 12)
    return qrFilter.outputImage?.transformed(by: qrTransform)
  }

  func qrImage(using color: UIColor? = nil, logo: UIImage? = nil, isDarkMode: Bool = false) -> CIImage? {
    guard let logo = logo?.cgImage else { return qrImage }  // Return QR if no logo is provided

    // Convert logo to CIImage
    let logoCIImage = CIImage(cgImage: logo)

    // Generate a palette and detect the accent color
    let palette = logoCIImage.generateColorPalette(clusterCount: 4)
    let accentColor = logoCIImage.detectAccentColor(fromPalette: palette, isDarkMode: isDarkMode)?.withAlphaComponent(
      1.0)

    // Tint the QR code with the detected accent color or fallback to the provided color
    let tintColor = accentColor ?? color ?? UIColor.black.withAlphaComponent(0.5)
    let tintedQRImage = qrImage?.tinted(using: tintColor)

    // Optional: Add rounded corners to the logo
    let cornerRadius = 0.2 * logoCIImage.extent.width
    guard let maskedLogo = logoCIImage.maskedWithRoundedRectangle(cornerRadius: cornerRadius) else {
      return tintedQRImage
    }

    // Combine the QR code and the logo
    return tintedQRImage?.combined(with: maskedLogo)
  }
}
