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
  case other(error: Error)

  var title: String {
    switch self {
    case .invalidURL:
      return "Something went wrong while creating the URL to download content"
    case .invalidResponseCode:
      return "Something went wrong while downloading the content"
    case .other:
      return "Error"
    }
  }

  var subtitle: String? {
    switch self {
    case .invalidURL:
      return "Please try again later"
    case .invalidResponseCode:
      return "Please try again later"
    case let .other(error):
      return error.localizedDescription
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
