//
//  ContentView.swift
//  AppExhibit
//
//  Created by Jan Armbrust on 27.05.24.
//

import SwiftData
import SwiftUI

struct ContentView: View {
  @Environment(\.modelContext) private var modelContext
  @Query private var items: [AppItem]

  @State private var showCreateAppSheet = false
  @State private var showPhotoZoomableSheet = false
  @State var selectedAppStoreLinkQRCodeData: Data? = nil

  var body: some View {
    NavigationStack {
      List {
        ForEach(items) { item in
          NavigationLink(value: item) {
            HStack {
              if let appIconData = item.icon, let appIcon = UIImage(data: appIconData) {
                AppIconView(appIcon: appIcon, size: 64)
              }
              Text(item.name)
              if let appStoreLinkQRCodeData = item.qrCode {
                Spacer()
                Image(systemName: "qrcode")
                  .onTapGesture {
                    selectedAppStoreLinkQRCodeData = appStoreLinkQRCodeData
                  }
                  .padding(.trailing)
              }
            }
          }
        }
        .onDelete(perform: deleteItems)
      }
      .navigationTitle("App Exhibit")
      .navigationDestination(for: AppItem.self) { item in
        AppDetailView(item: item)
      }
      .toolbar {
        ToolbarItem {
          Button(
            action: { showCreateAppSheet.toggle() }
          ) {
            Label("Add Item", systemImage: "plus")
          }
        }
      }
      .sheet(isPresented: $showCreateAppSheet) {
        CreateAppView()
      }
      .sheet(isPresented: $showPhotoZoomableSheet) {
        if let selectedAppStoreLinkQRCodeData {
          PhotoZoomableView(appStoreLinkQRCodeData: selectedAppStoreLinkQRCodeData)
            .presentationBackground(.ultraThinMaterial)
            .presentationCornerRadius(16)
        }
      }
      .task(id: selectedAppStoreLinkQRCodeData) {
        if selectedAppStoreLinkQRCodeData != nil {
          showPhotoZoomableSheet.toggle()
        }
      }
      .onChange(of: showPhotoZoomableSheet) { _, newValue in
        if newValue == false {
          selectedAppStoreLinkQRCodeData = nil
        }
      }
    }
  }

  private func deleteItems(offsets: IndexSet) {
    withAnimation {
      for index in offsets {
        modelContext.delete(items[index])
      }
    }
  }
}

#Preview {
  ContentView()
    .modelContainer(for: AppItem.self, inMemory: true)
}
