//
//  AppExhibitApp.swift
//  AppExhibit
//
//  Created by Jan Armbrust on 27.05.24.
//

import FreemiumKit
import SwiftData
import SwiftUI
import LinksKit

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
    self.configureLinksKit()
  }
  
  func configureLinksKit() {
    let ownConsumerApps = LinkSection(entries: [
      .link(.ownApp(id: "6472663048", name: "Cosmo Pic", systemImage: "photo.on.rectangle.angled")),
      .link(.ownApp(id: "6446234019", name: "Game Sheet", systemImage: "dice")),
    ])
    
    let cihatsApps = LinkSection(entries: [
      .link(.ownApp(id: "6502914189", name: "FreemiumKit: In-App Purchases", systemImage: "cart")),
      .link(.ownApp(id: "6480134993", name: "FreelanceKit: Time Tracking", systemImage: "timer")),
      .link(.ownApp(id: "6472669260", name: "CrossCraft: Crossword Tests", systemImage: "puzzlepiece")),
      .link(.ownApp(id: "6477829138", name: "FocusBeats: Study Music Timer", systemImage: "music.note")),
      .link(.ownApp(id: "6587583340", name: "Pleydia Organizer: Media Renamer", systemImage: "popcorn")),
      .link(.ownApp(id: "6479207869", name: "Guided Guest Mode: Device Demo", systemImage: "questionmark.circle")),
      .link(.ownApp(id: "6478062053", name: "Posters: Discover Movies at Home", systemImage: "movieclapper")),
    ])
    
    LinksKit.configure(
       providerToken: "123456",
       linkSections: [
          .helpLinks(appID: "6503256642", supportEmail: "appexhibit@xbow.dev"),
          .appMenus(
              ownAppLinks: [ownConsumerApps],
              friendsAppLinks: [cihatsApps]
           ),
          .legalLinks(privacyURL: URL(string: "https://xbow.dev/app-exhibit/privacy")!)
       ]
    )
  }

  var body: some Scene {
    WindowGroup {
      MainView()
        .environmentObject(FreemiumKit.shared)
    }
    .modelContainer(self.sharedModelContainer)
  }
}
