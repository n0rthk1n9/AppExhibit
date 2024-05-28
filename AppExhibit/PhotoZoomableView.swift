//
//  PhotoZoomableView.swift
//  AppExhibit
//
//  Created by Jan Armbrust on 28.05.24.
//

import SwiftUI

struct PhotoZoomableView: View {
  let appStoreLinkQRCodeData: Data

  @GestureState private var zoom = 1.0

  var body: some View {
    PhotoZoomableContainerView {
      if let appStoreLinkQRCode = UIImage(data: appStoreLinkQRCodeData) {
        Image(uiImage: appStoreLinkQRCode)
          .interpolation(.none)
          .resizable()
          .scaledToFit()
          .padding(.horizontal, 8)
          .scaleEffect(zoom)
      } else {
        Text("no image")
      }
    }
  }
}

// #Preview {
//  PhotoZoomableView(appIconQRCodeData: nil)
// }
