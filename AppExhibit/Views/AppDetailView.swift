//
//  AppDetailView.swift
//  AppExhibit
//
//  Created by Jan Armbrust on 27.05.24.
//

import SwiftUI

struct AppDetailView: View {
  @Environment(\.openURL) var openURL
  @Environment(\.colorScheme) var colorScheme

  let item: AppItem

  @State private var showPhotoZoomableSheet = false

  var body: some View {
    ScrollView {
      VStack(alignment: .leading) {
        HStack(alignment: .center) {
          if let appIconData = item.icon, let appIcon = UIImage(data: appIconData) {
            AppIconView(appIcon: appIcon)
          }
          VStack(alignment: .center) {
            HStack(alignment: .top) {
              Button {
                let impact = UIImpactFeedbackGenerator(style: .medium)
                impact.impactOccurred()
                showPhotoZoomableSheet.toggle()
              } label: {
                Image(systemName: "qrcode")
              }
              .modifier(DetailViewButtonStyle(color: .blue))
              if let appStoreUrl = URL(string: item.appStoreLink) {
                ShareLink(item: appStoreUrl) {
                  Image(systemName: "square.and.arrow.up")
                }
                .modifier(DetailViewButtonStyle(color: .blue))
              }

            }
            Button("Go to App Store Page") {
              let impact = UIImpactFeedbackGenerator(style: .medium)
              impact.impactOccurred()
              if let appStoreLink = URL(string: item.appStoreLink) {
                openURL(appStoreLink)
              }
            }
            .bold()
            .frame(maxWidth: .infinity, minHeight: 40)
            .foregroundStyle(.white)
            .background(.blue)
            .clipShape(RoundedRectangle(cornerRadius: 10))
          }
        }
        .padding(.bottom)
        if let screenshots = item.screenshots {
          ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
              ForEach(0..<screenshots.count, id: \.self) { index in
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

struct DetailViewButtonStyle: ViewModifier {
  @Environment(\.colorScheme) var colorScheme
  
  let color: Color

  func body(content: Content) -> some View {
    content
      .font(.title3)
      .bold()
      .frame(maxWidth: .infinity, minHeight: 40)
      .background(colorScheme == .dark ? .black : .white)
      .foregroundStyle(color)
      .clipShape(RoundedRectangle(cornerRadius: 10))
      .overlay(
        RoundedRectangle(cornerRadius: 10)
          .stroke(color, lineWidth: 2)
      )
  }
}

// Hack to making archive build work
#if DEBUG
  #Preview(traits: .sampleData) {
    AppDetailView(item: SampleData.sampleApp1)
  }
#endif
