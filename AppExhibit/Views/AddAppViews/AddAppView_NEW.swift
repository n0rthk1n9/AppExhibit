//
//  AddAppView_NEW.swift
//  AppExhibit
//
//  Created by Jan Armbrust on 02.12.2024.
//

import SwiftUI

struct AddAppView_NEW: View {
  @State private var progressState: ProgressState = .successful
  @State var appItem: AppItem = AppItem()
  
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
        }
    }
  }
}

#Preview {
  AddAppView_NEW(appStoreLink: "")
}
