//
//  FindByAppStoreLinkView.swift
//  AppExhibit
//
//  Created by Jan Armbrust on 30.05.24.
//

import SwiftUI

struct FindByAppStoreLinkView: View {
  @Environment(\.dismiss) private var dismiss

  @State private var viewModel = AddAppViewModel()
  @State private var newAppItem = AppItem()
  @State private var showCreateAppView = false

  var body: some View {
    NavigationStack {
      VStack {
        TextField("App Store Link", text: $newAppItem.appStoreLink)
          .textFieldStyle(RoundedBorderTextFieldStyle())
          .padding()

        Button("Find") {
          Task {
            await fetchAppDetails()
            showCreateAppView = true
          }
        }
        .buttonStyle(.borderedProminent)
        .disabled(newAppItem.appStoreLink.isEmpty)
        .padding()
      }
      .navigationTitle("Find App by link")
      .navigationDestination(isPresented: $showCreateAppView) {
        AddAppView(newAppItem: $newAppItem) {
          dismiss()
          showCreateAppView = false
        }
      }
      .showCustomAlert(alert: $viewModel.error)
    }
  }

  private func fetchAppDetails() async {
    let appID = viewModel.extractAppID(from: newAppItem.appStoreLink) ?? ""

    await viewModel.getAppDetails(for: appID)
    Task { @MainActor in
      newAppItem.name = viewModel.appDetails.first?.trackCensoredName ?? ""
    }

    await viewModel.getAppIcon()
    Task { @MainActor in
      newAppItem.icon = viewModel.appIcon
      newAppItem.appStoreDescription = viewModel.appDetails.first?.description ?? ""
    }

    await viewModel.getScreenshots()
    Task { @MainActor in
      newAppItem.screenshots = viewModel.screenshots
    }
  }
}

#Preview {
  FindByAppStoreLinkView()
}
