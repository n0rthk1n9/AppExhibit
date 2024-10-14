//
//  AppsView.swift
//  AppExhibit
//
//  Created by Jan Armbrust on 27.05.24.
//

import FreemiumKit
import SwiftData
import SwiftUI

struct AppsView: View {
  @Environment(\.modelContext) private var modelContext
  @Query(sort: \AppItem.name, order: .forward) private var items: [AppItem]

  @EnvironmentObject private var freemiumKit: FreemiumKit
  @State private var showPaywall: Bool = false

  private var canAddAnotherApp: Bool {
    self.items.isEmpty || self.freemiumKit.hasPurchased
  }

  @State private var showCreateAppSheet = false
  @State private var showFindByAppNameSheet = false
  @State private var showFindByAppStoreLinkSheet = false
  @State private var showFindByDeveloperSheet = false
  @State private var showPhotoZoomableSheet = false
  @State var selectedAppStoreLinkQRCodeData: Data? = nil

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
              Menu("Add", systemImage: "plus") {
                self.addMenuContents
              }
              .labelStyle(.iconOnly)
              .font(.title2)
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
        .toolbar {
          ToolbarItem {
            Menu("Add", systemImage: "plus") {
              self.addMenuContents
            }
          }
        }
        .navigationTitle("App Exhibit")
        .navigationDestination(for: AppItem.self) { item in
          AppDetailView(item: item)
        }
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
        .sheet(isPresented: self.$showFindByDeveloperSheet) {
          FindByDeveloperView()
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
        .paywall(isPresented: self.$showPaywall)
    }
  }

  @ViewBuilder
  private var addMenuContents: some View {
    if self.canAddAnotherApp {
      Button("Add by search", systemImage: "magnifyingglass") {
        self.showFindByAppNameSheet.toggle()
      }
      Button("Add by App Store link", systemImage: "link") {
        self.showFindByAppStoreLinkSheet.toggle()
      }
      Button("Add by developer", systemImage: "person") {
        self.showFindByDeveloperSheet.toggle()
      }
      Button("Add manually", systemImage: "plus") {
        self.showCreateAppSheet = true
      }
    } else {
      Button("Add by search", systemImage: "lock") {
        self.showPaywall = true
      }
      Button("Add by App Store link", systemImage: "lock") {
        self.showPaywall = true
      }
      Button("Add by developer", systemImage: "lock") {
        self.showPaywall = true
      }
      Button("Add manually", systemImage: "lock") {
        self.showPaywall = true
      }
    }
  }

  private func deleteItems(offsets: IndexSet) {
    withAnimation {
      for index in offsets {
        self.modelContext.delete(self.items[index])
      }
      saveContext(modelContext)
    }
  }
  
  private func saveContext(_ context: ModelContext) {
      do {
        try context.save()
      } catch {
        print("Failed to save model context: \(error)")
      }
    }
}

// Hack to making archive build work
#if DEBUG
#Preview(traits: .sampleData) {
  AppsView()
    .environmentObject(FreemiumKit.shared)
}
#endif
