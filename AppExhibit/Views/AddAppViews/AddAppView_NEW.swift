//
//  AddAppView_NEW.swift
//  AppExhibit
//
//  Created by Jan Armbrust on 02.12.2024.
//

import SwiftUI

struct AddAppView_NEW: View {
  @Environment(\.modelContext) private var modelContext
  @Environment(\.dismiss) var dismiss
  
  @State private var progressState: ProgressState = .notStarted
  @State var appItem: AppItem = AppItem()
  @State private var appDetails: [ITunesAPIResult] = []
  
  private let iTunesAPIService: ITunesAPIServiceProtocol = ITunesAPIService()
  
  let appStoreLink: String
  var onCreate: (() -> Void)?

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
              if let appIconData = appItem.icon, let appIcon = UIImage(data: appIconData) {
                AppIconView(appIcon: appIcon, size: 150)
              }
            }
            Section {
              TextField("App Store or TestFlight Link", text: $appItem.appStoreLink)
            }
          }
          .padding(.top)
          Button {
            addAppItem()
            if let onCreate {
              onCreate()
            } else {
              dismiss()
            }
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
      await createAppItem()
    }
  }
  
  private func createAppItem() async {
    if let appID = extractAppID(from: appStoreLink) {
      appItem.appStoreLink = appStoreLink
      await getAppDetails(for: appID)
      appItem.name = appDetails.first?.trackCensoredName ?? ""
      appItem.appStoreDescription = appDetails.first?.description ?? ""
      await getAppIcon()
      generateQRCodeIfNeeded()
      await getScreenshots()
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
  
  private func getAppDetails(for id: String) async {
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
  
  private func getAppIcon() async {
    self.progressState = .inProgress

    do {
      guard !appDetails.isEmpty else {
        self.progressState = .failed(error: AppExhibitError.notAnAppStoreLink)
        return
      }
      var appIconURL: URL?
      if let appIconURLString = appDetails.first?.artworkUrl100 {
        appIconURL = URL(string: appIconURLString)
      }
      if let appIconURL {
        (appItem.icon, _) = try await URLSession.shared.data(from: appIconURL)
      }
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
  
  private func generateQRCodeIfNeeded() {
    if let appIconData = appItem.icon, let appIconImage = UIImage(data: appIconData) {
      // Determine if the system is in dark mode
      let isDarkMode = UITraitCollection.current.userInterfaceStyle == .dark

      // Generate QR code with app icon as logo
      if let appStoreURL = URL(string: appStoreLink),
        let ciQRCodeImage = appStoreURL.qrImage(logo: appIconImage, isDarkMode: isDarkMode)
      {
        appItem.qrCode = UIImage(ciImage: ciQRCodeImage).pngData()
      }
    }
  }
  
  private func getScreenshots() async {
    self.progressState = .inProgress
    
    guard !appDetails.isEmpty else {
      self.progressState = .failed(error: AppExhibitError.notAnAppStoreLink)
      return
    }
    
    appItem.screenshots = []

    do {
      if let screenshotUrls = appDetails.first?.screenshotUrls {
        for screenshotUrlString in screenshotUrls {
          if let screenshotURL = URL(string: screenshotUrlString) {
            let (screenshotData, _) = try await URLSession.shared.data(from: screenshotURL)
            appItem.screenshots?.append(screenshotData)
          }
        }
      }
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
  
  private func addAppItem() {
    withAnimation {
      modelContext.insert(appItem)
    }
  }
}

#Preview {
  AddAppView_NEW(appStoreLink: "https://apps.apple.com/de/app/pixelmator-pro/id1289583905?l=en-GB&mt=12")
}
