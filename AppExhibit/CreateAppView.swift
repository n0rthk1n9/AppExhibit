//
//  CreateAppView.swift
//  AppExhibit
//
//  Created by Jan Armbrust on 27.05.24.
//

import CoreImage.CIFilterBuiltins
import PhotosUI
import SwiftUI

struct CreateAppView: View {
  @Environment(\.modelContext) private var modelContext
  @Environment(\.dismiss) var dismiss

  @State private var viewModel = CreateAppViewModel()
  @State private var newAppItem = AppItem()
  @State private var selectedPhoto: PhotosPickerItem?
  @State private var appStoreLinkQRCode = UIImage()

  let context = CIContext()
  let filter = CIFilter.qrCodeGenerator()

  var body: some View {
    NavigationStack {
      List {
        Section {
          if let appIconData = newAppItem.icon, let appIcon = UIImage(data: appIconData) {
            AppIconView(appIcon: appIcon)
          }
          PhotosPicker(
            selection: $selectedPhoto,
            matching: .images,
            photoLibrary: .shared()
          ) {
            Label("Select App Icon", systemImage: "photo")
          }
          if newAppItem.icon != nil {
            Button(role: .destructive) {
              withAnimation {
                selectedPhoto = nil
                newAppItem.icon = nil
              }
            } label: {
              Label("Remove App Icon", systemImage: "xmark")
                .foregroundStyle(.red)
            }
          }
        }
        Section {
          TextField("App Name", text: $newAppItem.name)
        }
        Section {
          TextField("App Store Link", text: $newAppItem.appStoreLink)
        }
        Section {
          Button("Fetch app data") {
            if !newAppItem.appStoreLink.isEmpty {
              var appID = ""
              Task {
                appID = viewModel.extractAppID(from: newAppItem.appStoreLink) ?? ""
                await viewModel.getAppDetails(for: appID)
                newAppItem.name = viewModel.appDetails.first?.trackCensoredName ?? ""
                await viewModel.getAppIcon()
                newAppItem.icon = viewModel.appIcon
              }
            }
          }
        }
        if !newAppItem.appStoreLink.isEmpty {
          Section {
            Image(uiImage: appStoreLinkQRCode)
              .interpolation(.none)
              .resizable()
              .scaledToFit()
              .frame(width: 200, height: 200)
          }
        }
        Section {
          Button("Create") {
            addAppItem()
            dismiss()
          }
        }
      }
      .navigationTitle("Create App")
      .task(id: selectedPhoto) {
        if let appIconData = try? await selectedPhoto?.loadTransferable(type: Data.self) {
          newAppItem.icon = appIconData
        }
      }
      .onChange(of: newAppItem.appStoreLink) { _, newAppStoreLink in
        withAnimation {
          appStoreLinkQRCode = generateQRCode(from: newAppStoreLink)
          newAppItem.qrCode = appStoreLinkQRCode.pngData()
        }
      }
    }
  }

  private func addAppItem() {
    withAnimation {
      modelContext.insert(newAppItem)
    }
  }

  private func generateQRCode(from appStoreLink: String) -> UIImage {
    filter.message = Data(appStoreLink.utf8)

    if let outputImage = filter.outputImage {
      if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
        return UIImage(cgImage: cgImage)
      }
    }

    return UIImage(systemName: "xmark.circle") ?? UIImage()
  }
}

#Preview {
  CreateAppView()
    .modelContainer(for: AppItem.self, inMemory: true)
}
