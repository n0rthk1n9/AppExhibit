//
//  FindByAppNameView.swift
//  AppExhibit
//
//  Created by Jan Armbrust on 30.05.24.
//

import SwiftUI

struct FindByAppNameView: View {
  @Environment(\.dismiss) private var dismiss

  @State private var viewModel = CreateAppViewModel()
  @State private var newAppItem = AppItem()

  var body: some View {
    NavigationStack {
      List(viewModel.apps, id: \.self) { app in
        NavigationLink {
          CreateAppView(newAppItem: $newAppItem) {
            dismiss()
          }
          .task {
            newAppItem.appStoreLink = app.trackViewUrl
            await fetchAppDetails()
            viewModel.searchTerm = ""
          }
        } label: {
          Text(app.trackCensoredName)
        }
      }
      .searchable(text: $viewModel.searchTerm)
      .navigationTitle("Search Apps")
      .task(id: viewModel.searchTerm) {
        viewModel.searchTask?.cancel()

        viewModel.searchTask = Task {
          try? await Task.sleep(nanoseconds: 300_000_000)
          await viewModel.getApps(for: viewModel.searchTerm)
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
  FindByAppNameView()
}
