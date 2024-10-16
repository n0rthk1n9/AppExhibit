//
//  MainView.swift
//  AppExhibit
//
//  Created by Jan Armbrust on 19.09.24.
//

import SwiftUI
import FreemiumKit

struct MainView: View {
    var body: some View {
      TabView {
        AppsView()
          .tabItem {
              Label("Apps", systemImage: "app")
          }
        SettingsView()
          .tabItem {
              Label("Settings", systemImage: "gear")
          }
      }
    }
}

// Hack to making archive build work
#if DEBUG
#Preview(traits: .sampleData) {
    MainView()
    .environmentObject(FreemiumKit.shared)
}
#endif
