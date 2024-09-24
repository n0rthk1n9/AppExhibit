//
//  SettingsView.swift
//  AppExhibit
//
//  Created by Jan Armbrust on 19.09.24.
//

import FreemiumKit
import SwiftUI

struct SettingsView: View {
  @Environment(\.openURL) private var openURL

  var body: some View {
    Form {
      Section {
        PaidStatusView(style: .decorative(icon: .laurel))
      }
      Section {
          Button("Terms and Conditions", systemImage: "text.book.closed") {
             self.openURL(URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
          }
          Button("Privacy", systemImage: "lock") {
             self.openURL(URL(string: "https://xbow.dev/app-exhibit/privacy")!)
          }
       }
    }
  }
}

#Preview {
    SettingsView()
}
