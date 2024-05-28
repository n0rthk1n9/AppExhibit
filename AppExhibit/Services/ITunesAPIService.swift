//
//  ITunesAPIService.swift
//  AppExhibit
//
//  Created by Jan Armbrust on 28.05.24.
//

import Foundation

struct ITunesAPIService: ITunesAPIServiceProtocol {
  var session: URLSession {
    let sessionConfiguration: URLSessionConfiguration
    sessionConfiguration = URLSessionConfiguration.default
    return URLSession(configuration: sessionConfiguration)
  }

  func fetchAppDetails(for id: String) async throws -> [ITunesAPIResult] {
    var urlComponents = URLComponents()
    urlComponents.scheme = "https"
    urlComponents.host = "itunes.apple.com"
    urlComponents.path = "/lookup"
    urlComponents.queryItems = [
      URLQueryItem(name: "id", value: id),
      URLQueryItem(name: "entity", value: "software")
    ]

    guard let url = urlComponents.url else {
      throw URLError(.cancelled)
    }

    let request = URLRequest(url: url)

    do {
      let (data, response) = try await session.data(for: request)
      guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
        throw URLError(.cancelled)
      }

      let iTunesAPIResults = try JSONDecoder().decode(ITunesAPIResults.self, from: data)
      let results = iTunesAPIResults.results
      return results
    } catch {
      throw error
    }
  }
}
