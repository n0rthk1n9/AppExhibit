//
//  ITunesAPIResults.swift
//  AppExhibit
//
//  Created by Jan Armbrust on 28.05.24.
//

import Foundation

struct ITunesAPIResults: Codable, Equatable, Hashable {
  let results: [ITunesAPIResult]

  enum CodingKeys: String, CodingKey {
    case results
  }
}

extension ITunesAPIResults {
  static func fixture(
    results: [ITunesAPIResult] = [
      ITunesAPIResult.fixture()
    ]
  ) -> ITunesAPIResults {
    ITunesAPIResults(
      results: results
    )
  }

  static var allProperties: ITunesAPIResults {
    .fixture(
      results: [
        ITunesAPIResult.allProperties
      ]
    )
  }
}
