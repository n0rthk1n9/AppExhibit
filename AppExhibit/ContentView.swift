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

  var body: some View {
    NavigationStack {
      List {
        ForEach(items) { item in
          NavigationLink(value: item) {
            HStack {
              if let appIconData = item.icon, let appIcon = UIImage(data: appIconData) {
                AppIconView(appIcon: appIcon)
              }
              Text(item.name)
            }
          }
        }
        .onDelete(perform: deleteItems)
      }
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
          .presentationDetents([.medium])
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
