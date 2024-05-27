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
  var timestamp: Date

  init(timestamp: Date) {
    self.timestamp = timestamp
  }
}
