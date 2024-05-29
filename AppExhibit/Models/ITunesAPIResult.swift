//
//  ITunesAPIResult.swift
//  AppExhibit
//
//  Created by Jan Armbrust on 28.05.24.
//

import Foundation

struct ITunesAPIResult: Codable, Equatable, Hashable {
  let trackCensoredName: String
  let artworkUrl100: String
  let description: String
  let screenshotUrls: [String]

  enum CodingKeys: String, CodingKey {
    case artworkUrl100, trackCensoredName, description, screenshotUrls
  }
}

extension ITunesAPIResult {
  static func fixture(
    trackCensoredName: String = "Cosmo Pic",
    artworkUrl100: String =
      "https://is1-ssl.mzstatic.com/image/thumb/Purple211/v4/ee/f0/d6/eef0d607-33c5-2b31-0b94-21c368476e43/AppIcon-0-0-1x_U007epad-0-85-220.png/100x100bb.jpg",
    description: String = "Amazing app",
    screenshotUrls: [String] =
      [
        "https://is1-ssl.mzstatic.com/image/thumb/PurpleSource112/v4/3b/05/2c/3b052c20-2da3-7d1a-334a-f16d81c7717b/6bdd7a89-d533-4429-bbed-2f6860a08064_1.png/392x696bb.png"
      ]

  ) -> ITunesAPIResult {
    ITunesAPIResult(
      trackCensoredName: trackCensoredName,
      artworkUrl100: artworkUrl100,
      description: description,
      screenshotUrls: screenshotUrls
    )
  }

  static var allProperties: ITunesAPIResult {
    .fixture(
      trackCensoredName: "Csomo Pic",
      artworkUrl100: "https://is1-ssl.mzstatic.com/image/thumb/Purple211/v4/ee/f0/d6/eef0d607-33c5-2b31-0b94-21c368476e43/AppIcon-0-0-1x_U007epad-0-85-220.png/100x100bb.jpg",
      description: "Amazing App",
      screenshotUrls:
      [
        "https://is1-ssl.mzstatic.com/image/thumb/PurpleSource112/v4/3b/05/2c/3b052c20-2da3-7d1a-334a-f16d81c7717b/6bdd7a89-d533-4429-bbed-2f6860a08064_1.png/392x696bb.png"
      ]
    )
  }
}
