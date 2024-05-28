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
      if let appStoreLinkQRCodeData = item.qrCode, let appStoreLinkQRCode = UIImage(data: appStoreLinkQRCodeData) {
        Image(uiImage: appStoreLinkQRCode)
          .interpolation(.none)
          .resizable()
          .scaledToFit()
          .frame(width: 200, height: 200)
      }
      Text(item.name)
    }
  }
}

#Preview {
  AppDetailView(item: AppItem())
}
