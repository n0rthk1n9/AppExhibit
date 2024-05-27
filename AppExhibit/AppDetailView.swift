//
//  AppDetailView.swift
//  AppExhibit
//
//  Created by Jan Armbrust on 27.05.24.
//

import SwiftUI

struct AppDetailView: View {
  let item: AppItem

  var body: some View {
    VStack {
      if let appIconData = item.icon, let appIcon = UIImage(data: appIconData) {
        AppIconView(appIcon: appIcon)
      }
      Text(item.name)
    }
  }
}

#Preview {
  AppDetailView(item: AppItem())
}
