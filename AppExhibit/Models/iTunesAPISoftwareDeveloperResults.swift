//
//  iTunesAPISoftwareDeveloperResults.swift
//  AppExhibit
//
//  Created by Jan Armbrust on 24.09.24.
//

import Foundation

struct iTunesAPISoftwareDeveloperResults: Codable, Equatable, Hashable {
    let resultCount: Int
    let results: [iTunesAPISoftwareDeveloperResult]

    enum CodingKeys: String, CodingKey {
        case resultCount, results
    }
}

extension iTunesAPISoftwareDeveloperResults {
    static func fixture(
        resultCount: Int = 1,
        results: [iTunesAPISoftwareDeveloperResult] = [
            iTunesAPISoftwareDeveloperResult.fixture()
        ]
    ) -> iTunesAPISoftwareDeveloperResults {
        iTunesAPISoftwareDeveloperResults(
            resultCount: resultCount,
            results: results
        )
    }

    static var allProperties: iTunesAPISoftwareDeveloperResults {
        .fixture(
            resultCount: 1,
            results: [
                iTunesAPISoftwareDeveloperResult.allProperties
            ]
        )
    }
}
