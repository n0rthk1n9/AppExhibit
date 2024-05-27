//
//  CreateAppView.swift
//  AppExhibit
//
//  Created by Jan Armbrust on 27.05.24.
//

import PhotosUI
import SwiftUI

struct CreateAppView: View {
  @Environment(\.modelContext) private var modelContext
  @Environment(\.dismiss) var dismiss

  @State private var newAppItem = AppItem()
  @State private var selectedPhoto: PhotosPickerItem?

  var body: some View {
    NavigationStack {
      List {
        Section {
          if let appIconData = newAppItem.icon, let appIcon = UIImage(data: appIconData) {
            Image(uiImage: appIcon)
              .resizable()
              .scaledToFit()
              .frame(width: 128, height: 128)
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
    }
  }

  private func addAppItem() {
    withAnimation {
      modelContext.insert(newAppItem)
    }
  }
}

#Preview {
  CreateAppView()
    .modelContainer(for: AppItem.self, inMemory: true)
}
