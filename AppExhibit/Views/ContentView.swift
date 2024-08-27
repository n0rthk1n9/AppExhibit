//
//  ContentView.swift
//  AppExhibit
//
//  Created by Jan Armbrust on 27.05.24.
//

import FreemiumKit
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
  @State var showPaywall: Bool = false

  var body: some View {
    NavigationStack {
      List {
        if self.items.isEmpty {
          ContentUnavailableView {
            Label("Add your first app", systemImage: "app.fill")
          } description: {
            Text(
              "Add all your precious apps you want to easily share with the people around you just by tapping the + button"
            )
          } actions: {
            Button {
              self.showFindByAppNameSheet.toggle()
            } label: {
              Image(systemName: "plus")
            }
          }

        } else {
          ForEach(self.items) { item in
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
                      self.selectedAppStoreLinkQRCodeData = appStoreLinkQRCodeData
                    }
                    .padding(.trailing)
                }
              }
            }
          }
          .onDelete(perform: self.deleteItems)
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
              if self.items.isEmpty || FreemiumKit.shared.hasPurchased {
                self.showFindByAppNameSheet.toggle()
              } else {
                self.showPaywall = true
              }
            } label: {
              if self.items.isEmpty || FreemiumKit.shared.hasPurchased {
                Label("Add by search", systemImage: "magnifyingglass")
              } else {
                Label("Add by search", systemImage: "lock")
              }
            }
            Button {
              if self.items.isEmpty || FreemiumKit.shared.hasPurchased {
                self.showFindByAppStoreLinkSheet.toggle()
              } else {
                self.showPaywall = true
              }
            } label: {
              if self.items.isEmpty || FreemiumKit.shared.hasPurchased {
                Label("Add by App Store link", systemImage: "link")
              } else {
                Label("Add by App Store link", systemImage: "lock")
              }
            }
            Button {
              if self.items.isEmpty || FreemiumKit.shared.hasPurchased {
                self.showCreateAppSheet.toggle()
              } else {
                self.showPaywall = true
              }
            } label: {
              if self.items.isEmpty || FreemiumKit.shared.hasPurchased {
                Label("Add manually", systemImage: "plus")
              } else {
                Label("Add manually", systemImage: "lock")
              }
            }
          } label: {
            Label("Add App", systemImage: "plus")
          }
        }
      }
      .paywall(isPresented: self.$showPaywall)
      .sheet(isPresented: self.$showCreateAppSheet) {
        AddAppView(viewModel: .constant(AddAppViewModel()), newAppItem: .constant(AppItem()))
      }
      .sheet(isPresented: self.$showFindByAppNameSheet) {
        FindByAppNameView()
      }
      .sheet(isPresented: self.$showFindByAppStoreLinkSheet) {
        FindByAppStoreLinkView()
      }
      .sheet(isPresented: self.$showPhotoZoomableSheet) {
        if let selectedAppStoreLinkQRCodeData {
          PhotoZoomableView(appStoreLinkQRCodeData: selectedAppStoreLinkQRCodeData)
            .presentationBackground(.ultraThinMaterial)
            .presentationCornerRadius(16)
        }
      }
      .task(id: self.selectedAppStoreLinkQRCodeData) {
        if self.selectedAppStoreLinkQRCodeData != nil {
          self.showPhotoZoomableSheet.toggle()
        }
      }
      .onChange(of: self.showPhotoZoomableSheet) { _, newValue in
        if newValue == false {
          self.selectedAppStoreLinkQRCodeData = nil
        }
      }
    }
  }

  private func deleteItems(offsets: IndexSet) {
    withAnimation {
      for index in offsets {
        self.modelContext.delete(self.items[index])
      }
    }
  }
}

#Preview {
  ContentView()
    .modelContainer(for: AppItem.self, inMemory: true)
}
