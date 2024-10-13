//
//  AppItem.swift
//  AppExhibit
//
//  Created by Jan Armbrust on 27.05.24.
//

import Foundation
import SwiftData

@Model
final class AppItem {
  var icon: Data?
  var name: String
  var appStoreLink: String
  var qrCode: Data?
  var appStoreDescription: String?
  var screenshots: [Data]?

  init(icon: Data = Data(), name: String = "", appStoreLink: String = "", qrCode: Data = Data(), appStoreDescription: String = "", screenshots: [Data] = [Data()]) {
    self.icon = icon
    self.name = name
    self.appStoreLink = appStoreLink
    self.qrCode = qrCode
    self.appStoreDescription = appStoreDescription
    self.screenshots = screenshots
  }
}
