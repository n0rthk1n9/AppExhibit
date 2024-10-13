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
        switch viewModel.loadingState {
        case .notStarted:

          TextField("App Store Link", text: $newAppItem.appStoreLink)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding()

          Button(action: {
            Task {
              await fetchAppDetails()
            }
          }) {
            Text("Find App")
              .frame(maxWidth: .infinity)
              .font(.title2)
              .bold()
              .padding(.horizontal)
              .padding(.vertical, 8)
          }
          .buttonStyle(.borderedProminent)
          .padding()
          .disabled(newAppItem.appStoreLink.isEmpty)

        case .inProgress:
          ProgressView("Getting app details…")

        case .failed(let error):
          ContentUnavailableView {
            Label("Adding by App Store link failed", systemImage: "x.circle")
          } description: {
            Text(error.localizedDescription)
          } actions: {
            Button("Try Again", systemImage: "arrow.circlepath") {
              viewModel.loadingState = .notStarted
            }
          }

        case .successful:
          TextField("App Store Link", text: $newAppItem.appStoreLink)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding()

          Button(action: {
            Task {
              await fetchAppDetails()
            }
          }) {
            Text("Find App")
              .frame(maxWidth: .infinity)
              .font(.title2)
              .bold()
              .padding(.horizontal)
              .padding(.vertical, 8)
          }
          .buttonStyle(.borderedProminent)
          .padding()
          .disabled(newAppItem.appStoreLink.isEmpty)

        }
      }
      .navigationTitle("Find App by link")
      .navigationDestination(isPresented: $showCreateAppView) {
        AddAppView(viewModel: $viewModel, newAppItem: $newAppItem) {
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
    switch viewModel.loadingState {
      
    case .notStarted:
      showCreateAppView = false
    case .inProgress:
      showCreateAppView = false
    case .failed(error: _):
      showCreateAppView = false
    case .successful:
      showCreateAppView = true
    }
  }
}

#Preview {
  FindByAppStoreLinkView()
}
