//
//  AppIconView.swift
//  AppExhibit
//
//  Created by Jan Armbrust on 27.05.24.
//

import SwiftUI

struct AppIconView: View {
  let appIcon: UIImage
  var size: CGFloat = 128

  var body: some View {
    ZStack {
      Image(uiImage: appIcon)
        .resizable()
        .scaledToFit()
        .frame(width: size, height: size)
        .clipShape(
          RoundedRectangle(cornerRadius: 0.2 * size, style: .continuous)
        )
    }
    .padding(.trailing)
  }
}

#Preview {
  AppIconView(appIcon: UIImage(systemName: "star")!)
}
