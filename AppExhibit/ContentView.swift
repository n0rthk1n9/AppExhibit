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
          NavigationLink {
            Text(item.name)
          } label: {
            Text(item.name)
          }
        }
        .onDelete(perform: deleteItems)
      }
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          EditButton()
        }
        ToolbarItem {
          Button(action: addItem) {
            Label("Add Item", systemImage: "plus")
          }
        }
      }
      .sheet(isPresented: $showCreateAppSheet) {
        CreateApp()
          .presentationDetents([.medium])
      }
    }
  }

  private func addItem() {
    withAnimation {
      let newItem = AppItem(name: "Test")
      modelContext.insert(newItem)
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
