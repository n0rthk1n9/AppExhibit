//
//  ShareViewController.swift
//  ShareExtension
//
//  Created by Jan Armbrust on 03.06.24.
//

import SwiftData
import SwiftUI
import UIKit
import UniformTypeIdentifiers

class ShareViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()

    // Ensure access to extensionItem and itemProvider
    guard
      let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem,
      let itemProvider = extensionItem.attachments?.first
    else {
      close()
      return
    }

    // Check type identifier
    let urlDataType = UTType.url.identifier
    if itemProvider.hasItemConformingToTypeIdentifier(urlDataType) {
      // Load the item from itemProvider
      itemProvider.loadItem(forTypeIdentifier: urlDataType, options: nil) { providedUrl, error in
        if error != nil {
          self.close()
          return
        }

        if let url = providedUrl as? URL {
          DispatchQueue.main.async {
            let sharedModelContainer: ModelContainer = {
              let schema = Schema([
                AppItem.self,
              ])
              let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

              do {
                return try ModelContainer(for: schema, configurations: [modelConfiguration])
              } catch {
                fatalError("Could not create ModelContainer: \(error)")
              }
            }()

            // host the SwiftU view
            let contentView = UIHostingController(
              rootView: ShareExtensionView(url: url)
                .modelContainer(sharedModelContainer)
            )
            self.addChild(contentView)
            self.view.addSubview(contentView.view)

            // set up constraints
            contentView.view.translatesAutoresizingMaskIntoConstraints = false
            contentView.view.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
            contentView.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
            contentView.view.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
            contentView.view.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
          }
        } else {
          self.close()
          return
        }
      }

    } else {
      close()
      return
    }

    NotificationCenter.default.addObserver(forName: NSNotification.Name("close"), object: nil, queue: nil) { _ in
      DispatchQueue.main.async {
        self.close()
      }
    }
  }

  /// Close the Share Extension
  func close() {
    extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
  }
}
