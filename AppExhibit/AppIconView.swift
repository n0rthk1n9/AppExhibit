//
//  AppIconView.swift
//  AppExhibit
//
//  Created by Jan Armbrust on 27.05.24.
//

import SwiftUI

struct AppIconView: View {
  let appIcon: UIImage

  var body: some View {
    ZStack {
      Image(uiImage: appIcon)
        .resizable()
        .scaledToFill()
        .frame(width: 128, height: 128)
        .clipShape(
          RoundedRectangle(cornerRadius: 25.6, style: .continuous)
        )
    }
    .padding()
  }
}

#Preview {
  AppIconView(appIcon: UIImage(systemName: "star")!)
}
