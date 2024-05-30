//
//  Binding+Extension.swift
//  AppExhibit
//
//  Created by Jan Armbrust on 30.05.24.
//

import SwiftUI

extension Binding where Value == Bool {
  init<T>(value: Binding<T?>) {
    self.init {
      value.wrappedValue != nil
    } set: { newValue in
      if !newValue {
        value.wrappedValue = nil
      }
    }
  }
}
