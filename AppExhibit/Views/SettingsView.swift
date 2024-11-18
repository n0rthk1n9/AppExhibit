//
//  SettingsView.swift
//  AppExhibit
//
//  Created by Jan Armbrust on 19.09.24.
//

import FreemiumKit
import SwiftUI
import LinksKit

struct SettingsView: View {
  @Environment(\.openURL) private var openURL

  var body: some View {
    Form {
      Section {
        PaidStatusView(style: .decorative(icon: .laurel))
          .listRowBackground(Color.accentColor)
          .padding(.vertical, -10)
      }

      #if !os(macOS)
      LinksView()
      #endif
    }
  }
}

#Preview {
    SettingsView()
    .environmentObject(FreemiumKit.shared)
}
