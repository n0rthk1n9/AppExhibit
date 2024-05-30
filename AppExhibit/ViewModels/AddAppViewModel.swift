//
//  AddAppViewModel.swift
//  AppExhibit
//
//  Created by Jan Armbrust on 28.05.24.
//

import Foundation

@Observable
class AddAppViewModel {
  var appDetails: [ITunesAPIResult] = []
  var appIcon: Data?
  var screenshots: [Data] = []
  var apps: [ITunesAPIResult] = []
  var searchTerm: String = ""
  var appStoreLink: String = ""

  var isLoading = false

  @ObservationIgnored
  private let iTunesAPIService: ITunesAPIServiceProtocol

  @ObservationIgnored
  var searchTask: Task<Void, Never>?

  init(iTunesAPIService: ITunesAPIServiceProtocol = ITunesAPIService()) {
    self.iTunesAPIService = iTunesAPIService
  }

  @MainActor
  func getAppDetails(for id: String) async {
    isLoading = true

    do {
      let fetchedAppDetails = try await iTunesAPIService.fetchAppDetails(for: id)

      appDetails = fetchedAppDetails

    } catch {
      print(error)
    }
    isLoading = false
  }

  @MainActor
  func getApps(for searchTerm: String) async {
    isLoading = true

    do {
      let fetchedApps = try await iTunesAPIService.fetchApps(for: searchTerm)

      apps = fetchedApps

    } catch {
      print(error)
    }
    isLoading = false
  }

  func extractAppID(from urlString: String) -> String? {
    guard let url = URL(string: urlString) else {
      return nil
    }

    let pathComponents = url.pathComponents
    let regexPattern = #"id(\d+)"#

    do {
      let regex = try NSRegularExpression(pattern: regexPattern)
      for component in pathComponents {
        let range = NSRange(location: 0, length: component.utf16.count)
        if let match = regex.firstMatch(in: component, options: [], range: range) {
          if let idRange = Range(match.range(at: 1), in: component) {
            return String(component[idRange])
          }
        }
      }
    } catch {
      print("Invalid regular expression")
      return nil
    }

    return nil
  }

  @MainActor
  func getAppIcon() async {
    isLoading = true

    do {
      if !appDetails.isEmpty {
        var appIconURL: URL?
        if let appIconURLString = appDetails.first?.artworkUrl100 {
          appIconURL = URL(string: appIconURLString)
        }
        if let appIconURL {
          (appIcon, _) = try await URLSession.shared.data(from: appIconURL)
        }
      }
    } catch {
      print(error)
    }
  }

  @MainActor
  func getScreenshots() async {
    isLoading = true

    screenshots = []

    do {
      if let screenshotUrls = appDetails.first?.screenshotUrls {
        for screenshotUrlString in screenshotUrls {
          if let screenshotURL = URL(string: screenshotUrlString) {
            let (screenshotData, _) = try await URLSession.shared.data(from: screenshotURL)
            screenshots.append(screenshotData)
          }
        }
      }
    } catch {
      print(error)
    }
    isLoading = false
  }
}
