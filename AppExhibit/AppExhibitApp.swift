//
//  AppExhibitApp.swift
//  AppExhibit
//
//  Created by Jan Armbrust on 27.05.24.
//

import FreemiumKit
import SwiftData
import SwiftUI

@main
struct AppExhibitApp: App {
  var sharedModelContainer: ModelContainer = {
    let schema = Schema([
      AppItem.self,
    ])
    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

    do {
      return try ModelContainer(for: schema, configurations: [modelConfiguration])
    } catch {
      fatalError("Could not create ModelContainer: \(error)")
    }
  }()

  init() {
    FreemiumKit.shared.lastPaidRelease(version: "1.1", buildNum: 6)
  }

  var body: some Scene {
    WindowGroup {
      MainView()
        .environmentObject(FreemiumKit.shared)
    }
    .modelContainer(self.sharedModelContainer)
  }
}
