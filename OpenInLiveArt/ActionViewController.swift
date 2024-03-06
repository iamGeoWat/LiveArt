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
    
    func openContainerApp(type: String) {

        let scheme = "shortcuts://x-callback-url/run-shortcut?name=Set%20LivePhoto%20Wallpaper"

        let url: URL = URL(string: scheme)!

        let context = NSExtensionContext()

        context.open(url, completionHandler: nil)
        print(123123123)

        var responder = self as UIResponder?

        let selectorOpenURL = sel_registerName("openURL:")

        while (responder != nil) {

            if responder!.responds(to: selectorOpenURL) {

                responder!.perform(selectorOpenURL, with: url)

                break

            }

            responder = responder?.next

        }

        self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)

    }
    
    func openApp(with url: URL) {
        // Construct a URL that your app can handle
        let customURL = "liveart://open?sharedURL=\(url.absoluteString)"
        
        let context = self.extensionContext!
        let url = URL(string: customURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
//        let url = URL(string: customURL)!
        
        // Use the extension context to open the URL (to launch your app)
        context.open(url, completionHandler: { (success) in
            if !success {
                // Handle the error, or alert the user if the app can't be opened
                print("Failed to open app with URL: \(url)")
            }
            
            // Complete the request to return to the host app
            self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Look for a URL instead of an image
        var urlFound = false
//        self.openApp(with: URL(string: "https://music.apple.com/us/playlist/breaking-r-b/pl.c270d4d09b3c441783076160a6f8325e")!)
        self.openContainerApp(type: "a")
//        for item in self.extensionContext!.inputItems as! [NSExtensionItem] {
//            for provider in item.attachments! {
//                if provider.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
//                    // This is a URL. We'll open our app with this URL.
//                    provider.loadItem(forTypeIdentifier: UTType.url.identifier, options: nil, completionHandler: { (urlItem, error) in
//                        OperationQueue.main.addOperation {
//                            if let url = urlItem as? URL {
//                                self.openApp(with: url)
//                            }
//                        }
//                    })
//                    
//                    urlFound = true
//                    break
//                }
//            }
//            
//            if (urlFound) {
//                // We only handle one URL, so stop looking for more.
//                break
//            }
//        }
    }

    @IBAction func done() {
        // Return any edited content to the host app.
        // This template doesn't do anything, so we just echo the passed in items.
        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
    }

}
