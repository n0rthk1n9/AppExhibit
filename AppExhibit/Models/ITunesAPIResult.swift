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

  enum CodingKeys: String, CodingKey {
    case artworkUrl100, trackCensoredName
  }
}

extension ITunesAPIResult {
  static func fixture(
    trackCensoredName: String = "Cosmo Pic",
    artworkUrl100: String =
      "https://is1-ssl.mzstatic.com/image/thumb/Purple211/v4/ee/f0/d6/eef0d607-33c5-2b31-0b94-21c368476e43/AppIcon-0-0-1x_U007epad-0-85-220.png/100x100bb.jpg"

  ) -> ITunesAPIResult {
    ITunesAPIResult(
      trackCensoredName: trackCensoredName,
      artworkUrl100: artworkUrl100
    )
  }

  static var allProperties: ITunesAPIResult {
    .fixture(
      trackCensoredName: "Csomo Pic",
      artworkUrl100: "https://is1-ssl.mzstatic.com/image/thumb/Purple211/v4/ee/f0/d6/eef0d607-33c5-2b31-0b94-21c368476e43/AppIcon-0-0-1x_U007epad-0-85-220.png/100x100bb.jpg"
    )
  }
}
