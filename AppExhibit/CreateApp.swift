//
//  CreateApp.swift
//  AppExhibit
//
//  Created by Jan Armbrust on 27.05.24.
//

import SwiftUI

struct CreateApp: View {
  @Environment(\.dismiss) var dismiss

  @State private var appItem = AppItem()

  var body: some View {
    NavigationStack {
      List {
        TextField("App Name", text: $appItem.name)
        Button("Create") {
          dismiss()
        }
      }
      .navigationTitle("Create App")
    }
  }
}

#Preview {
  CreateApp()
}
