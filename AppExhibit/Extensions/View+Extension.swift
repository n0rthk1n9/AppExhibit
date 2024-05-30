//
//  View+Extension.swift
//  AppExhibit
//
//  Created by Jan Armbrust on 30.05.24.
//

import SwiftUI

extension View {
  func showCustomAlert<T: AppExhibitAlert>(alert: Binding<T?>) -> some View {
    self
      .alert(alert.wrappedValue?.title ?? "Error", isPresented: Binding(value: alert), actions: {
        alert.wrappedValue?.buttons
      }, message: {
        if let subtitle = alert.wrappedValue?.subtitle {
          Text(subtitle)
        }
      })
  }
}
