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
      Section(header: Text("Subscription")) {
        PaidStatusView(style: .decorative(icon: .laurel))
      }
      #if !os(macOS)
      LinksView()
      #endif
    }
  }
}

#Preview {
    SettingsView()
}
