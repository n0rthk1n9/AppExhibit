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
      throw AppExhibitError.invalidURL
    }

    let request = URLRequest(url: url)

    do {
      let (data, response) = try await session.data(for: request)
      guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
        throw AppExhibitError.invalidResponseCode
      }

      let iTunesAPIResults = try JSONDecoder().decode(ITunesAPIResults.self, from: data)
      let results = iTunesAPIResults.results
      return results
    } catch {
      throw error
    }
  }

    func fetchApps(for searchTerm: String) async throws -> [ITunesAPIResult] {
      let urlEncodedSearchTerm = searchTerm.replacingOccurrences(of: " ", with: "+")
      var urlComponents = URLComponents()
      urlComponents.scheme = "https"
      urlComponents.host = "itunes.apple.com"
      urlComponents.path = "/search"
      urlComponents.queryItems = [
        URLQueryItem(name: "term", value: urlEncodedSearchTerm),
        URLQueryItem(name: "entity", value: "software")
      ]

      guard let url = urlComponents.url else {
        throw AppExhibitError.invalidURL
      }

      let request = URLRequest(url: url)

      do {
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
          throw AppExhibitError.invalidResponseCode
        }

        let iTunesAPIResults = try JSONDecoder().decode(ITunesAPIResults.self, from: data)
        let results = iTunesAPIResults.results
        return results
      } catch {
        throw error
      }
    }

  func fetchSoftwareDeveloper(for developerName: String) async throws -> iTunesAPISoftwareDeveloperResults {
          let urlEncodedDeveloperName = developerName.replacingOccurrences(of: " ", with: "+")
          var urlComponents = URLComponents()
          urlComponents.scheme = "https"
          urlComponents.host = "itunes.apple.com"
          urlComponents.path = "/search"
          urlComponents.queryItems = [
              URLQueryItem(name: "term", value: urlEncodedDeveloperName),
              URLQueryItem(name: "attribute", value: "softwareDeveloper"),
              URLQueryItem(name: "entity", value: "softwareDeveloper")
          ]
          guard let url = urlComponents.url else {
              throw AppExhibitError.invalidURL
          }
          let request = URLRequest(url: url)
          do {
              let (data, response) = try await session.data(for: request)
              guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                  throw AppExhibitError.invalidResponseCode
              }
              let decoder = JSONDecoder()
              let results = try decoder.decode(iTunesAPISoftwareDeveloperResults.self, from: data)
              return results
          } catch {
              throw error // Let the calling function handle the error
          }
      }

  func fetchDeveloperApps(for developerId: Int) async throws -> [ITunesAPIResult] {
          var urlComponents = URLComponents()
          urlComponents.scheme = "https"
          urlComponents.host = "itunes.apple.com"
          urlComponents.path = "/lookup"
          urlComponents.queryItems = [
              URLQueryItem(name: "id", value: String(developerId)),
              URLQueryItem(name: "entity", value: "software,iPadSoftware,macSoftware")
          ]

          guard let url = urlComponents.url else {
              throw AppExhibitError.invalidURL
          }

          let request = URLRequest(url: url)

          do {
              let (data, response) = try await session.data(for: request)

              guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                  throw AppExhibitError.invalidResponseCode
              }

              // Parse the JSON data
              guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                    let results = json["results"] as? [[String: Any]] else {
                  throw AppExhibitError.other(error: NSError(domain: "ITunesAPIService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON structure"]))
              }

              // Filter out the developer info
              let appResults = results.filter { ($0["wrapperType"] as? String) == "software" }

              // Encode the filtered results back to Data
              let filteredData = try JSONSerialization.data(withJSONObject: ["results": appResults], options: [])

              // Decode the filtered data
              let decoder = JSONDecoder()
              let decodedResults = try decoder.decode(ITunesAPIResults.self, from: filteredData)

              // Remove duplicates based on trackViewUrl
              let uniqueResults = Array(Dictionary(grouping: decodedResults.results, by: { $0.trackViewUrl })
                  .values
                  .compactMap { $0.first })

              return uniqueResults
          } catch {
              throw AppExhibitError.other(error: error)
          }
      }
}
