//
//  AppDetailView.swift
//  AppExhibit
//
//  Created by Jan Armbrust on 27.05.24.
//

import SwiftUI

struct AppDetailView: View {
  let item: AppItem

  @State private var showPhotoZoomableSheet = false

  var body: some View {
    ScrollView {
      VStack(alignment: .leading) {
        HStack(alignment: .top) {
          if let appIconData = item.icon, let appIcon = UIImage(data: appIconData) {
            AppIconView(appIcon: appIcon)
          }
          Image(systemName: "qrcode")
            .font(.largeTitle)
            .onTapGesture {
              showPhotoZoomableSheet.toggle()
            }
        }
        .padding(.bottom)
        if let screenshots = item.screenshots {
          ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
              ForEach(0 ..< screenshots.count, id: \.self) { index in
                if let screenshot = UIImage(data: screenshots[index]) {
                  Image(uiImage: screenshot)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 400)
                    .cornerRadius(20)
                }
              }
            }
          }
          .padding(.bottom)
        }
        Text(item.appStoreDescription ?? "")
      }
      .padding()
    }
    .sheet(isPresented: $showPhotoZoomableSheet) {
      if let qrCode = item.qrCode {
        PhotoZoomableView(appStoreLinkQRCodeData: qrCode)
          .presentationBackground(.ultraThinMaterial)
          .presentationCornerRadius(16)
      }
    }
    .navigationTitle(item.name)
  }
}

#Preview {
  AppDetailView(item: AppItem())
}
