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
        Image(uiImage: appIcon)
          .resizable()
          .scaledToFit()
          .frame(width: 128, height: 128)
      }
      Text(item.name)
    }
  }
}

#Preview {
  AppDetailView(item: AppItem())
}
