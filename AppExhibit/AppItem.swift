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
  var qrCode: Data?

  init(name: String) {
    self.name = name
  }
}
