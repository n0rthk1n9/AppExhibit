//
//  FindByAppStoreLinkView.swift
//  AppExhibit
//
//  Created by Jan Armbrust on 30.05.24.
//

import SwiftUI

struct FindByAppStoreLinkView: View {
  @Environment(\.dismiss) private var dismiss

  @State private var viewModel = CreateAppViewModel()
  @State private var newAppItem = AppItem()
  @State private var showCreateAppView = false

  var body: some View {
    NavigationStack {
      VStack {
        TextField("App Store Link", text: $newAppItem.appStoreLink)
          .textFieldStyle(RoundedBorderTextFieldStyle())
          .padding()

        Button("Fetch app data") {
          if !newAppItem.appStoreLink.isEmpty {
            Task {
              await fetchAppDetails()
              showCreateAppView = true
            }
          }
        }
        .padding()
      }
      .navigationTitle("Paste Link")
      .navigationDestination(isPresented: $showCreateAppView) {
        CreateAppView(newAppItem: $newAppItem) {
          dismiss()
          showCreateAppView = false
        }
      }
    }
  }

  private func fetchAppDetails() async {
    let appID = viewModel.extractAppID(from: newAppItem.appStoreLink) ?? ""
    await viewModel.getAppDetails(for: appID)
    newAppItem.name = viewModel.appDetails.first?.trackCensoredName ?? ""
    await viewModel.getAppIcon()
    newAppItem.icon = viewModel.appIcon
    newAppItem.appStoreDescription = viewModel.appDetails.first?.description ?? ""
    await viewModel.getScreenshots()
    newAppItem.screenshots = viewModel.screenshots
  }
}

#Preview {
  FindByAppStoreLinkView()
}
