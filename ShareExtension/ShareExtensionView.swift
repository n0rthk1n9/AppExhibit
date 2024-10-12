//
//  ShareExtensionView.swift
//  ShareExtension
//
//  Created by Jan Armbrust on 03.06.24.
//

import FreemiumKit
import SwiftUI

struct ShareExtensionView: View {
  @State private var url: URL
  @State private var viewModel = AddAppViewModel()
  @State private var newAppItem = AppItem()
  @State private var showCreateAppView = false
  @State var showPaywall = false
  let onDismiss: () -> Void  // Add this line

  init(url: URL, onDismiss: @escaping () -> Void) {  // Update initializer
    self.url = url
    self.onDismiss = onDismiss  // Set the onDismiss closure
    _newAppItem = State(initialValue: AppItem(appStoreLink: url.absoluteString))
  }

  var body: some View {
    NavigationStack {
      VStack {
        TextField("App Store Link", text: $newAppItem.appStoreLink)
          .textFieldStyle(RoundedBorderTextFieldStyle())
          .padding()

        PaidFeatureView {
          Button {
            Task {
              await fetchAppDetails()
              showCreateAppView = true
            }
          } label: {
            if viewModel.isLoading {
              ProgressView()
            } else {
              Label("Find by app link", systemImage: "link")
            }
          }
          .buttonStyle(.borderedProminent)
          .disabled(newAppItem.appStoreLink.isEmpty || viewModel.isLoading)
          .padding()
        } lockedView: {
          Button("Find by app link", systemImage: "lock") {
            self.showPaywall = true
          }
          .buttonStyle(.borderedProminent)
        }
      }
      .paywall(isPresented: $showPaywall)
      .navigationTitle("Find App by link")
      .navigationDestination(isPresented: $showCreateAppView) {
        AddAppView(viewModel: $viewModel, newAppItem: $newAppItem) {
          onDismiss()
          showCreateAppView = false
        }
      }
      .toolbar {
        Button("Cancel") {
          onDismiss()
        }
      }
      .showCustomAlert(alert: $viewModel.error)
      .onPurchasesLoaded {
        if !FreemiumKit.shared.hasPurchased {
          self.showPaywall = true
        }
      }
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
  ShareExtensionView(url: URL(string: "https://apple.com")!) {
    print("Preview: Dismiss action triggered")
  }
}
