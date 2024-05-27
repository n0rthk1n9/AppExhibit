//
//  CreateAppView.swift
//  AppExhibit
//
//  Created by Jan Armbrust on 27.05.24.
//

import SwiftUI

struct CreateAppView: View {
  @Environment(\.modelContext) private var modelContext
  @Environment(\.dismiss) var dismiss

  @State private var newAppItem = AppItem()

  var body: some View {
    NavigationStack {
      List {
        TextField("App Name", text: $newAppItem.name)
        Button("Create") {
          addAppItem()
          dismiss()
        }
      }
      .navigationTitle("Create App")
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
