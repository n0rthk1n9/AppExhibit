//
//  iTunesAPISoftwareDeveloperResult.swift
//  AppExhibit
//
//  Created by Jan Armbrust on 24.09.24.
//

import Foundation

struct iTunesAPISoftwareDeveloperResult: Codable, Equatable, Hashable {
    let wrapperType: String
    let artistType: String
    let artistName: String
    let artistLinkUrl: String
    let artistId: Int

    enum CodingKeys: String, CodingKey {
        case wrapperType, artistType, artistName, artistLinkUrl, artistId
    }
}

extension iTunesAPISoftwareDeveloperResult {
    static func fixture(
        wrapperType: String = "artist",
        artistType: String = "Software Artist",
        artistName: String = "Cihat Guenduez",
        artistLinkUrl: String = "https://apps.apple.com/us/developer/cihat-guenduez/id556786619?uo=4",
        artistId: Int = 556786619
    ) -> iTunesAPISoftwareDeveloperResult {
        iTunesAPISoftwareDeveloperResult(
            wrapperType: wrapperType,
            artistType: artistType,
            artistName: artistName,
            artistLinkUrl: artistLinkUrl,
            artistId: artistId
        )
    }

    static var allProperties: iTunesAPISoftwareDeveloperResult {
        .fixture(
            wrapperType: "artist",
            artistType: "Software Artist",
            artistName: "Cihat Guenduez",
            artistLinkUrl: "https://apps.apple.com/us/developer/cihat-guenduez/id556786619?uo=4",
            artistId: 556786619
        )
    }
}
