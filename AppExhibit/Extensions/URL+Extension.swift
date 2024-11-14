//
//  URL+Extension.swift
//  AppExhibit
//
//  Created by Jan Armbrust on 12/11/24.
//

import SwiftUI

extension URL {

  func qrImage(using color: UIColor, logo: UIImage? = nil) -> CIImage? {
      let tintedQRImage = qrImage?.tinted(using: color)

      guard let logo = logo?.cgImage else {
          return tintedQRImage
      }
      
      let logoCIImage = CIImage(cgImage: logo)
    
      let cornerRadius = 0.2 * logoCIImage.extent.width
      guard let maskedLogo = logoCIImage.maskedWithRoundedRectangle(cornerRadius: cornerRadius) else {
          return tintedQRImage
      }
      
      return tintedQRImage?.combined(with: maskedLogo)
  }

    /// Returns a black and white QR code for this URL.
    var qrImage: CIImage? {
        guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        let qrData = absoluteString.data(using: String.Encoding.ascii)
        qrFilter.setValue(qrData, forKey: "inputMessage")

        let qrTransform = CGAffineTransform(scaleX: 12, y: 12)
        return qrFilter.outputImage?.transformed(by: qrTransform)
    }
}
