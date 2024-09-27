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
              List {
                  if let developerResults = viewModel.developerResults {
                      ForEach(developerResults.results, id: \.artistId) { developer in
                          Button(action: {
                              viewModel.selectDeveloper(developer)
                          }) {
                              Text(developer.artistName)
                          }
                      }
                  } else if !viewModel.isLoading {
                      Text("Search for a developer")
                  }

                  if let selectedDeveloper = viewModel.selectedDeveloper {
                      Section(header: Text("Apps by \(selectedDeveloper.artistName)")) {
                          if viewModel.developerApps.isEmpty && !viewModel.isLoading {
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
              .navigationTitle("Find App by Developer")
              .overlay {
                  if viewModel.isLoading {
                      ProgressView()
                  }
              }
              .showCustomAlert(alert: $viewModel.error)
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
