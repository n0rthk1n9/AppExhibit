//
//  FindByAppNameView_NEW.swift
//  AppExhibit
//
//  Created by Jan Armbrust on 02.12.2024.
//

import SwiftUI

struct FindByAppNameView_NEW: View {
  @Environment(\.dismiss) private var dismiss
  
  @State private var progressState: ProgressState = .notStarted
  @State private var searchTerm: String = ""
  @State private var apps: [ITunesAPIResult] = []
  
  private let iTunesAPIService: ITunesAPIServiceProtocol = ITunesAPIService()
  
  var body: some View {
    NavigationStack {
      Group {
        switch progressState {
        case .notStarted:
          ContentUnavailableView(
            "Start searching",
            systemImage: "magnifyingglass",
            description: Text("Enter the name of an app on the App Store to find it")
          )
        case .inProgress:
          ProgressView("Searching…")
        case .failed:
          Text("Failed to find app")
        case .successful:
          List {
            ForEach(apps, id: \.self) { app in
              Text(app.trackCensoredName)
            }
          }
        }
      }
      .navigationTitle("Find App by name")
    }
    .searchable(text: $searchTerm, prompt: "Enter app name")
    .onChange(of: searchTerm) { oldValue, newValue in
      guard !newValue.isEmpty else { return }
      Task {
        try? await Task.sleep(for: .milliseconds(300))
        await search()
      }
    }
  }
  
  private func search() async {
    progressState = .inProgress
    
    do {
      apps = try await iTunesAPIService.fetchApps(for: searchTerm)
    } catch {
      progressState = .failed(error: AppExhibitError.invalidResponseCode)
      print("could not fetch apps")
    }
    
    progressState = .successful
  }
}

#Preview {
  FindByAppNameView_NEW()
}
