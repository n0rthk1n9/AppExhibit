//
//  FindByAppNameView.swift
//  AppExhibit
//
//  Created by Jan Armbrust on 30.05.24.
//

import SwiftUI

struct FindByAppNameView: View {
  @Environment(\.dismiss) private var dismiss

  @State private var viewModel = AddAppViewModel()
  @State private var newAppItem = AppItem()

  var body: some View {
    NavigationStack {
      List(viewModel.apps, id: \.self) { app in
        NavigationLink {
          AddAppView(newAppItem: $newAppItem) {
            dismiss()
          }
          .task {
            newAppItem.appStoreLink = app.trackViewUrl
            await fetchAppDetails()
            viewModel.searchTerm = ""
          }
        } label: {
          HStack {
            if let appIconURL = URL(string: app.artworkUrl100) {
              AsyncImage(url: appIconURL) { image in
                image
                  .resizable()
                  .scaledToFit()
                  .frame(width: 32, height: 32)
                  .clipShape(
                    RoundedRectangle(cornerRadius: 0.2 * 32, style: .continuous)
                  )
              } placeholder: {
                ProgressView()
                  .frame(width: 32, height: 32)
              }
              .padding(.trailing)
            }
            Text(app.trackCensoredName)
          }
        }
      }
      .navigationTitle("Find App by name")
    }
    .searchable(text: $viewModel.searchTerm)
    .task(id: viewModel.searchTerm) {
      if !viewModel.searchTerm.isEmpty {
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
