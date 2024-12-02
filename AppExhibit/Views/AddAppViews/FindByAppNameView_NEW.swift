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
          Text("App found")
        }
      }
      .navigationTitle("Find App by name")
    }
    .searchable(text: $searchTerm, prompt: "Enter app name")
  }
}

#Preview {
  FindByAppNameView_NEW()
}
