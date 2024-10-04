//
//  FindByDeveloperView.swift
//  AppExhibit
//
//  Created by Jan Armbrust on 24.09.24.
//

import SwiftUI

struct FindByDeveloperView: View {
  @Environment(\.dismiss) private var dismiss
  @State private var viewModel = FindByDeveloperViewModel()
  @State private var addAppViewModel = AddAppViewModel()
  @State private var newAppItem = AppItem()

  var body: some View {
    NavigationStack {
      Group {
        switch viewModel.loadingState {
        case .notStarted:
          ContentUnavailableView(
            "Start searching",
            systemImage: "magnifyingglass",
            description: Text("Enter the name of a developer on the App Store to find their apps")
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
                await viewModel.searchDevelopers()
              }
            }
          }

        case .successful:
          self.resultsList
        }
      }
      .navigationTitle("Find App by Developer")
    }
    .searchable(text: $viewModel.searchTerm, prompt: "Enter developer name")
    .onChange(of: viewModel.searchTerm) { oldValue, newValue in
      guard !newValue.isEmpty else { return }
      viewModel.searchTask?.cancel()
      viewModel.searchTask = Task {
        try? await Task.sleep(for: .milliseconds(300))
        await viewModel.searchDevelopers()
      }
    }
  }

  var resultsList: some View {
    List {
      if let developerResults = viewModel.developerResults {
        ForEach(developerResults.results, id: \.artistId) { developer in
          Button(action: {
            viewModel.selectDeveloper(developer)
          }) {
            Text(developer.artistName)
          }
        }
      }

      if let selectedDeveloper = viewModel.selectedDeveloper {
        Section(header: Text("Apps by \(selectedDeveloper.artistName)")) {
          if viewModel.developerApps.isEmpty {
            Text("No apps found for this developer")
          } else {
            ForEach(viewModel.developerApps, id: \.trackViewUrl) { app in
              NavigationLink {
                AddAppView(viewModel: $addAppViewModel, newAppItem: $newAppItem) {
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
                        .clipShape(RoundedRectangle(cornerRadius: 0.2 * 32, style: .continuous))
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
      }
    }
  }

  private func fetchAppDetails() async {
    let appID = addAppViewModel.extractAppID(from: newAppItem.appStoreLink) ?? ""
    await addAppViewModel.getAppDetails(for: appID)
    newAppItem.name = addAppViewModel.appDetails.first?.trackCensoredName ?? ""
    await addAppViewModel.getAppIcon()
    newAppItem.icon = addAppViewModel.appIcon
    newAppItem.appStoreDescription = addAppViewModel.appDetails.first?.description ?? ""
    await addAppViewModel.getScreenshots()
    newAppItem.screenshots = addAppViewModel.screenshots
  }
}

#Preview {
  FindByDeveloperView()
}
