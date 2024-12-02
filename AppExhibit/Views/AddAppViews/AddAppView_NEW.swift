//
//  AddAppView_NEW.swift
//  AppExhibit
//
//  Created by Jan Armbrust on 02.12.2024.
//

import SwiftUI

struct AddAppView_NEW: View {
  @State private var progressState: ProgressState = .notStarted
  @State var appItem: AppItem = AppItem()
  @State private var appDetails: [ITunesAPIResult] = []
  
  private let iTunesAPIService: ITunesAPIServiceProtocol = ITunesAPIService()
  
  let appStoreLink: String

  var body: some View {
    NavigationStack {
        switch progressState {
        case .notStarted:
          ContentUnavailableView(
            "Download about to start",
            systemImage: "magnifyingglass",
            description: Text("Hand tight, we're connecting to the internet right now")
          )
        case .inProgress:
          ProgressView("Fetching app details...")
        case .failed:
          Text("Failed to find app")
        case .successful:
          Form {
            Section {
              TextField("App Name", text: $appItem.name)
            }
            Section {
              Rectangle()
                .fill(Color.blue)
                .frame(width: 100, height: 100)
            }
            Section {
              TextField("App Store or TestFlight Link", text: $appItem.appStoreLink)
            }
          }
          .padding(.top)
          Button {
            // add app
          } label: {
            Text("Add")
              .frame(maxWidth: .infinity)
              .font(.title2)
              .bold()
              .padding(.horizontal)
              .padding(.vertical, 8)
          }
          .buttonStyle(.borderedProminent)
          .padding()
          .navigationTitle("Add App")
        }
    }
    .task {
      await fetchAppDetails()
    }
  }
  
  private func fetchAppDetails() async {
    if let appID = extractAppID(from: appItem.appStoreLink) {
      await getAppDetails(for: appID)
      appItem.name = appDetails.first?.trackCensoredName ?? ""
    }
  }
  
  private func extractAppID(from urlString: String) -> String? {
    progressState = .inProgress

    guard !urlString.isEmpty else {
      progressState = .failed(error: AppExhibitError.notAnAppStoreLink)
      return nil
    }

    guard let url = URL(string: urlString) else {
      progressState = .failed(error: AppExhibitError.notAnAppStoreLink)
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
    } catch let error as AppExhibitError {
      progressState = .failed(error: error)
      return nil
    } catch {
      if (error as? URLError)?.code == .cancelled {
        return nil
      }
      progressState = .failed(error: .other(error: error))
      return nil
    }

    progressState = .successful

    return nil
  }
  
  func getAppDetails(for id: String) async {
    self.progressState = .inProgress

    do {
      let fetchedAppDetails = try await iTunesAPIService.fetchAppDetails(for: id)

      appDetails = fetchedAppDetails

    } catch let error as AppExhibitError {
      self.progressState = .failed(error: error)
    } catch {
      if (error as? URLError)?.code == .cancelled {
        return
      }
      self.progressState = .failed(error: .other(error: error))
    }

    self.progressState = .successful
  }
}

#Preview {
  AddAppView_NEW(appStoreLink: "https://apps.apple.com/de/app/pixelmator-pro/id1289583905?l=en-GB&mt=12")
}
