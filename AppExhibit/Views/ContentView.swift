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
  @State private var showFindByAppNameSheet = false
  @State private var showFindByAppStoreLinkSheet = false
  @State private var showPhotoZoomableSheet = false
  @State var selectedAppStoreLinkQRCodeData: Data? = nil

  var body: some View {
    NavigationStack {
      List {
        if items.isEmpty {
          ContentUnavailableView {
            Label("Add your first app", systemImage: "app.fill")
          } description: {
            Text(
              "Add all your precious apps you want to easily share with the people around you just by tapping the + button"
            )
          } actions: {
            Button {
              showFindByAppNameSheet.toggle()
            } label: {
              Image(systemName: "plus")
            }
          }

        } else {
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
      }
      .navigationTitle("App Exhibit")
      .navigationDestination(for: AppItem.self) { item in
        AppDetailView(item: item)
      }
      .toolbar {
        ToolbarItem {
          Menu {
            Button {
              showFindByAppNameSheet.toggle()
            } label: {
              Label("Add by search", systemImage: "magnifyingglass")
            }
            Button {
              showFindByAppStoreLinkSheet.toggle()
            } label: {
              Label("Add by App Store link", systemImage: "link")
            }
            Button {
              showCreateAppSheet.toggle()
            } label: {
              Label("Add manually", systemImage: "plus")
            }
          } label: {
            Label("Add App", systemImage: "plus")
          }
        }
      }
      .sheet(isPresented: $showCreateAppSheet) {
        AddAppView(viewModel: .constant(AddAppViewModel()), newAppItem: .constant(AppItem()))
      }
      .sheet(isPresented: $showFindByAppNameSheet) {
        FindByAppNameView()
      }
      .sheet(isPresented: $showFindByAppStoreLinkSheet) {
        FindByAppStoreLinkView()
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
