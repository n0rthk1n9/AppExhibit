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
      Group {
        switch viewModel.loadingState {
        case .notStarted:
          ContentUnavailableView(
            "Start searching",
            systemImage: "magnifyingglass",
            description: Text("Enter the name of an app on the App Store to find it")
          )

        case .inProgress:
          ProgressView("Searching…")

        case .failed(let error):
          ContentUnavailableView {
            Label("Search Failed", systemImage: "exclamationmark.magnifyingglass")
          } description: {
            Text(error.localizedDescription)
          } actions: {
            Button("Try Again", systemImage: "arrow.circlepath") {
              viewModel.searchTask = Task {
                await viewModel.getApps()
              }
            }
          }

        case .successful:
          self.resultsList
        }
      }
      .navigationTitle("Find App by name")
    }
    .searchable(text: $viewModel.searchTerm, prompt: "Enter app name")
    .onChange(of: viewModel.searchTerm, { oldValue, newValue in
      guard !newValue.isEmpty else { return }
      viewModel.searchTask?.cancel()
      viewModel.searchTask = Task {
        try? await Task.sleep(for: .milliseconds(300))
        await viewModel.getApps()
      }
    })
  }

  var resultsList: some View {
    List {
      ForEach(viewModel.apps, id: \.self) { app in
        NavigationLink {
          AddAppView(viewModel: $viewModel, newAppItem: $newAppItem) {
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
