//
//  AppExhibitError.swift
//  AppExhibit
//
//  Created by Jan Armbrust on 30.05.24.
//

import SwiftUI

enum AppExhibitError: Error, LocalizedError, AppExhibitAlert {
  case invalidURL
  case invalidResponseCode
  case notAnAppStoreLink
  case other(error: Error)

  var title: String {
    switch self {
    case .invalidURL:
      return "Something went wrong while creating the URL to download content"
    case .invalidResponseCode:
      return "Something went wrong while downloading the content"
    case .notAnAppStoreLink:
      return "This is not an App Store link"
    case .other:
      return "Unknown Error"
    }
  }

  var subtitle: String? {
    switch self {
    case .invalidURL:
      return "Please try again later"
    case .invalidResponseCode:
      return "Please try again later"
    case .notAnAppStoreLink:
      return "App Exhibit can only use App Store links to add your apps"
    case let .other(error):
      return error.localizedDescription
    }
  }

  var errorDescription: String? {
    switch self {
    case .invalidURL: title
    case .invalidResponseCode: title
    case .notAnAppStoreLink: title
    case .other(let error): "\(title): \(error.localizedDescription)"
    }
  }

  var buttons: AnyView {
    AnyView(getButtonsForAlert)
  }

  @ViewBuilder var getButtonsForAlert: some View {
    switch self {
    default:
      Button("OK") {}
    }
  }
}
