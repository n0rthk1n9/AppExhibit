//
//  AddAppView.swift
//  AppExhibit
//
//  Created by Jan Armbrust on 27.05.24.
//

import CoreImage.CIFilterBuiltins
import PhotosUI
import SwiftData
import SwiftUI

struct AddAppView: View {
  @Environment(\.modelContext) private var modelContext
  @Environment(\.dismiss) var dismiss

  @Binding var viewModel: AddAppViewModel
  @Binding var newAppItem: AppItem
  @State private var selectedPhoto: PhotosPickerItem?
  @State private var appStoreLinkQRCode = UIImage()

  let context = CIContext()
  let filter = CIFilter.qrCodeGenerator()
  var onCreate: (() -> Void)?

  var body: some View {
    NavigationStack {
      VStack {
        Form {
          Section {
            TextField("App Name", text: $newAppItem.name)
          }
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
            TextField("App Store or TestFlight Link", text: $newAppItem.appStoreLink)
          }
        }
        Button {
          addAppItem()
          if let onCreate {
            onCreate()
          } else {
            dismiss()
          }
        } label: {
          if viewModel.isLoadingScreenshots {
            ProgressView {
              Text("Loading screenshots")
            }
          } else {
            Text("Add")
              .padding(.vertical, 5)
              .frame(minWidth: 200)
          }
        }
        .disabled(
          newAppItem.name.isEmpty || newAppItem.appStoreLink.isEmpty || viewModel.isLoading
            || viewModel
              .isLoadingScreenshots
        )
        .buttonStyle(.borderedProminent)
        .padding()
      }
      .navigationTitle("Add App")
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
      .onAppear {
        if !newAppItem.appStoreLink.isEmpty {
          withAnimation {
            appStoreLinkQRCode = generateQRCode(from: newAppItem.appStoreLink)
            newAppItem.qrCode = appStoreLinkQRCode.pngData()
          }
        }
      }
    }
  }

  private func addAppItem() {
    withAnimation {
      modelContext.insert(newAppItem)
      saveContext(modelContext)
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

  private func saveContext(_ context: ModelContext) {
    do {
      try context.save()
    } catch {
      print("Failed to save model context: \(error)")
    }
  }
}

#Preview(traits: .sampleData) {
  AddAppView(viewModel: .constant(AddAppViewModel()), newAppItem: .constant(SampleData.sampleApp1))
}
