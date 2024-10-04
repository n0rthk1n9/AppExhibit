//
//  DeveloperSearchViewModel.swift
//  AppExhibit
//
//  Created by Jan Armbrust on 24.09.24.
//

import Foundation

@Observable
class FindByDeveloperViewModel {
  var developerResults: iTunesAPISoftwareDeveloperResults?
  var selectedDeveloper: iTunesAPISoftwareDeveloperResult?
  var developerApps: [ITunesAPIResult] = []
  var searchTerm: String = ""

  var loadingState: ProgressState = .notStarted

  @ObservationIgnored
  private let iTunesAPIService: ITunesAPIServiceProtocol

  @ObservationIgnored
  var searchTask: Task<Void, Never>?

  init(iTunesAPIService: ITunesAPIServiceProtocol = ITunesAPIService()) {
    self.iTunesAPIService = iTunesAPIService
  }

  @MainActor
  func searchDevelopers() async {
    guard !searchTerm.isEmpty else { return }

    self.loadingState = .inProgress
    developerResults = nil
    selectedDeveloper = nil
    developerApps = []

    do {
      developerResults = try await iTunesAPIService.fetchSoftwareDeveloper(for: searchTerm)
    } catch let error as AppExhibitError {
      self.loadingState = .failed(error: error)
    } catch {
      if let urlError = error as? URLError, urlError.code == .cancelled {
        // Silently handle cancellation
        return
      }
      self.loadingState = .failed(error: .other(error: error))
    }

    self.loadingState = .successful
  }

  @MainActor
  func selectDeveloper(_ developer: iTunesAPISoftwareDeveloperResult) {
    selectedDeveloper = developer
    Task {
      await getDeveloperApps()
    }
  }

  @MainActor
  func getDeveloperApps() async {
    guard let developerId = selectedDeveloper?.artistId else { return }

    self.loadingState = .inProgress
    developerApps = []

    do {
      developerApps = try await iTunesAPIService.fetchDeveloperApps(for: developerId)
      if developerApps.isEmpty {
        print("No apps found for developer with ID: \(developerId)")
      }
    } catch let error as AppExhibitError {
      self.loadingState = .failed(error: error)
      print("AppExhibitError: \(error)")
    } catch {
      if let urlError = error as? URLError, urlError.code == .cancelled {
        // Silently handle cancellation
        return
      }
      self.loadingState = .failed(error: .other(error: error))
      print("Other error: \(error)")
    }

    self.loadingState = .successful
  }
}
