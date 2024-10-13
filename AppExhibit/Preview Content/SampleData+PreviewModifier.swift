//
//  SampleData+PreviewModifier.swift
//  AppExhibit
//
//  Created by Jan Armbrust on 12/10/24.
//

import SwiftData
import SwiftUI

extension SampleData: PreviewModifier {
  static func makeSharedContext() throws -> ModelContainer {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try ModelContainer(
      for: AppItem.self,
      configurations: config
    )

    for app in SampleData.sampleApps {
      container.mainContext.insert(app)
    }

    return container
  }

  func body(content: Content, context: ModelContainer) -> some View {
    content
      .modelContainer(context)
  }
}

extension PreviewTrait where T == Preview.ViewTraits {
  @MainActor static var sampleData: Self = .modifier(SampleData())
}
