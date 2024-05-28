//
//  CreateAppViewModel.swift
//  AppExhibit
//
//  Created by Jan Armbrust on 28.05.24.
//

import Foundation

@Observable
class CreateAppViewModel {
  var results: [ITunesAPIResult] = []
  var isLoading = false

  @ObservationIgnored
  private let iTunesAPIService: ITunesAPIServiceProtocol

  init(iTunesAPIService: ITunesAPIServiceProtocol = ITunesAPIService()) {
    self.iTunesAPIService = iTunesAPIService
  }

  @MainActor
  func getResults() async {
    isLoading = true

    do {
      let fetchedResults = try await iTunesAPIService.fetchAppDetails(for: "6472663048")

      results = fetchedResults
      print("loaded from web \(results.first?.artworkUrl100)")

    } catch {
      print(error)
    }
    isLoading = false
  }
}
