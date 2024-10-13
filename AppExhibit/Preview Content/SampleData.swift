//
//  SampleData.swift
//  AppExhibit
//
//  Created by Jan Armbrust on 12/10/24.
//

import CoreImage.CIFilterBuiltins
import SwiftUI

struct SampleData {
  static var sampleApps: [AppItem] = [sampleApp1, sampleApp2, sampleApp3]
  
  static var sampleApp1 = AppItem(
    icon: loadIconData(from: "sampleIconSampleApp1"),
    name: "Cosmo Pic",
    appStoreLink: "https://apps.apple.com/us/app/cosmo-pic/id6472663048?uo=4",
    qrCode: generateQRCode(from: "https://apps.apple.com/us/app/cosmo-pic/id6472663048?uo=4"),
    appStoreDescription: """
      Explore the Universe Daily with Cosmo Pic

      Cosmo Pic transforms your device into a window to the cosmos, delivering high quality astronomy pictures directly to you. With Cosmo Pic, the beauty of the universe unfolds in a new image every day, inviting you to embark on an unparalleled cosmic journey.

      ● Daily Discovery
      Astronomy Picture of the Day: Immerse yourself in the splendor of the cosmos with breathtaking space images. Each day brings a new view of the universe, designed to inspire and enlighten.

      ● Personalised Galaxy
      Favorites Gallery: Curate your collection of cosmic wonders. Revisit your favorite space images anytime, complete with in-depth descriptions that unveil the mysteries of the universe. Add or remove favorites to tailor your gallery to your celestial curiosity.

      ● Time Travel
      1-Month History: Dive into the recent past with access to the last 30 days of space imagery.

      ● Free Experience
      Enjoy features ad-free. For sharing space photos with friends and saving them to your photos, opt for a one-time purchase to unlock that feature.

      Whether you're an astronomy enthusiast, a student of the cosmos, or simply in awe of the universe's beauty, Cosmo Pic is your daily gateway to the stars. Start your exploration of the universe with Cosmo Pic - where the wonders of the universe are always within reach.
      """,
    screenshots: loadScreenshots(from: ["screenshot1SampleApp1", "screenshot2SampleApp1", "screenshot3SampleApp1"])
  )
  
  static var sampleApp2 = AppItem(
    icon: loadIconData(from: "sampleIconSampleApp2"),
    name: "Game Sheet",
    appStoreLink: "https://apps.apple.com/us/app/game-sheet/id6446234019?uo=4",
    qrCode: generateQRCode(from: "https://apps.apple.com/us/app/game-sheet/id6446234019?uo=4"),
    appStoreDescription: """
      Looking for an app to help you keep track of scores while playing your favorite dice game involving rolling six dice to achieve specific combinations? Our app is the perfect solution! With our user-friendly interface, you can easily enter and update scores for each player, no matter how many players are involved.

      But that's not all! Our app also offers data saving and syncing all your scores via iCloud. This allows you to securely save the scores of all players you add to your game and access them from all your devices. Whether you're playing on your iPhone, iPad, or Mac, you'll always have the most up-to-date scores at your fingertips.

      And with our emphasis on privacy and security, you can trust that your scores will always be kept safe and confidential. Our app stores your scores in your private iCloud, so you can focus on the game without worrying about anything else.

      Don't wait any longer - download our app today and enjoy the convenience, reliability, and security that it offers!
      """,
    screenshots: loadScreenshots(from: ["screenshot1SampleApp2", "screenshot2SampleApp2", "screenshot3SampleApp2"])
  )
  
  static var sampleApp3 = AppItem(
    icon: loadIconData(from: "sampleIconSampleApp3"),
    name: "App Exhibit: Your App Showcase",
    appStoreLink: "https://apps.apple.com/us/app/app-exhibit-your-app-showcase/id6503256642?uo=4",
    qrCode: generateQRCode(from: "https://apps.apple.com/us/app/app-exhibit-your-app-showcase/id6503256642?uo=4"),
    appStoreDescription: """
      App Exhibit: Showcase Your Apps Effortlessly

      Are you an indie developer or tech enthusiast who frequently attends conferences, meetups, or networking events? App Exhibit is the perfect companion for you! This powerful app allows you to showcase your apps and share them quickly and effortlessly with anyone around you via QR code.

      Key Features:

      ● Instant Sharing: Generate QR codes for your apps to share them instantly with others. No need for lengthy explanations or searching through the App Store.
      ● Offline Access: All your app data is stored securely on your device, ensuring you have access anytime, anywhere, without the need for an internet connection.
      ● Enhanced Visibility: Show your apps’ screenshots and descriptions, and provide a direct link to the App Store for instant access.
      ● Quick Setup: Simple and intuitive setup process. Add your apps in just a two steps and start sharing right away.
      ● Secure and Private: Your data stays on your device, ensuring privacy and security without relying on external servers.

      You can try all of the above with one of your apps for completely for free. If you have more than one app you want to add, you need the App Exhibit Pro Lifetime one-time purchase.

      ----- Legal Notice ----- 
      Terms of Use (EULA): https://www.apple.com/legal/internet-services/itunes/dev/stdeula/
      """,
    screenshots: loadScreenshots(from: ["screenshot1SampleApp3", "screenshot2SampleApp3", "screenshot3SampleApp3"])
  )

  static let context = CIContext()
  static let filter = CIFilter.qrCodeGenerator()

  static func generateQRCode(from appStoreLink: String) -> Data {
    filter.message = Data(appStoreLink.utf8)

    if let outputImage = filter.outputImage {
      if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
        let uiImage = UIImage(cgImage: cgImage)
        return uiImage.pngData() ?? fallbackIconData()
      }
    }

    return fallbackIconData()
  }

  static func loadIconData(from imageName: String) -> Data {
    if let image = UIImage(named: imageName),
      let imageData = image.pngData()
    {
      return imageData
    }

    return fallbackIconData()
  }
  
  static func loadScreenshots(from screenshotNames: [String]) -> [Data] {
      return screenshotNames.map { loadIconData(from: $0) }
  }

  static func fallbackIconData() -> Data {
    let defaultImage = UIImage(systemName: "xmark.circle.fill") ?? UIImage()
    return defaultImage.pngData() ?? Data()
  }
}
