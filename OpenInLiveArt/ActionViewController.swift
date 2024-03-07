//
//  ActionViewController.swift
//  OpenInLiveArt
//
//  Created by GeoWat on 2024/3/6.
//

import UIKit
import MobileCoreServices
import UniformTypeIdentifiers

class ActionViewController: UIViewController {
    
    func openURLInApp(url: URL) -> Bool {
        let customURL = "liveart://open?sharedURL=\(url.absoluteString)"
        let filteredURL = URL(string: customURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
        do {
            let application = try self.sharedApplication()
            var didSuccess = false
            application.open(filteredURL, options: [:]) { success in
                didSuccess = success
            }
            return didSuccess
        }
        catch {
            return false
        }
    }

    func sharedApplication() throws -> UIApplication {
        var responder: UIResponder? = self
        while responder != nil {
            if let application = responder as? UIApplication {
                return application
            }

            responder = responder?.next
        }

        throw NSError(domain: "UIInputViewController+sharedApplication.swift", code: 1, userInfo: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        var urlFound = false
        for item in self.extensionContext!.inputItems as! [NSExtensionItem] {
            for provider in item.attachments! {
                if provider.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
                    // This is a URL. We'll open our app with this URL.
                    provider.loadItem(forTypeIdentifier: UTType.url.identifier, options: nil, completionHandler: { (urlItem, error) in
                        OperationQueue.main.addOperation {
                            if let url = urlItem as? URL {
                                let res = self.openURLInApp(url: url)
                                print(res)
                            }
                        }
                    })
                    
                    urlFound = true
                    break
                }
            }
            
            if (urlFound) {
                // We only handle one URL, so stop looking for more.
                break
            }
        }
    }
}
