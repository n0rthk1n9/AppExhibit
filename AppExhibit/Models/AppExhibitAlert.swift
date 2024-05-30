//
//  AppExhibitAlert.swift
//  AppExhibit
//
//  Created by Jan Armbrust on 30.05.24.
//

import SwiftUI

protocol AppExhibitAlert {
  var title: String { get }
  var subtitle: String? { get }
  var buttons: AnyView { get }
}
