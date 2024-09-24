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
import FreemiumKit

class ShareViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem,
              let attachments = extensionItem.attachments else {
            close()
            return
        }

        let urlDataType = UTType.url.identifier

        // Find the first attachment that conforms to URL type
        for attachment in attachments {
            if attachment.hasItemConformingToTypeIdentifier(urlDataType) {
                loadURLFromAttachment(attachment)
                return
            }
        }

        // If we get here, no URL attachment was found
        close()
    }

    private func loadURLFromAttachment(_ itemProvider: NSItemProvider) {
        let urlDataType = UTType.url.identifier
        itemProvider.loadItem(forTypeIdentifier: urlDataType, options: nil) { [weak self] providedUrl, error in
            guard let self = self else { return }

            if error != nil {
                self.close()
                return
            }

            if let url = providedUrl as? URL {
                DispatchQueue.main.async {
                    let sharedModelContainer: ModelContainer = {
                        let schema = Schema([AppItem.self])
                        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
                        do {
                            return try ModelContainer(for: schema, configurations: [modelConfiguration])
                        } catch {
                            fatalError("Could not create ModelContainer: \(error)")
                        }
                    }()

                    let contentView = UIHostingController(
                        rootView: ShareExtensionView(url: url)
                            .modelContainer(sharedModelContainer)
                            .environmentObject(FreemiumKit.shared)
                    )
                    self.addChild(contentView)
                    self.view.addSubview(contentView.view)

                    contentView.view.translatesAutoresizingMaskIntoConstraints = false
                    NSLayoutConstraint.activate([
                        contentView.view.topAnchor.constraint(equalTo: self.view.topAnchor),
                        contentView.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
                        contentView.view.leftAnchor.constraint(equalTo: self.view.leftAnchor),
                        contentView.view.rightAnchor.constraint(equalTo: self.view.rightAnchor)
                    ])
                }
            } else {
                self.close()
            }
        }
    }

    func close() {
        extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
