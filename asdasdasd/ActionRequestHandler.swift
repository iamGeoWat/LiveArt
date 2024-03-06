//
//  ActionRequestHandler.swift
//  asdasdasd
//
//  Created by GeoWat on 2024/3/6.
//

import UIKit
import MobileCoreServices
import UniformTypeIdentifiers

class ActionRequestHandler: NSObject, NSExtensionRequestHandling {

    var extensionContext: NSExtensionContext?
    
    func openApp(with url: URL) {
        // Construct a URL that your app can handle
        let customURL = "liveart://open?url=\(url.absoluteString)"
        
        let context = self.extensionContext!
        let url = URL(string: customURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
        
        // Use the extension context to open the URL (to launch your app)
        context.open(url, completionHandler: { (success) in
            if !success {
                // Handle the error, or alert the user if the app can't be opened
                print("Failed to open app with URL: \(customURL)")
            }
            
            // Complete the request to return to the host app
            self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
        })
    }

    func beginRequest(with context: NSExtensionContext) {
        self.extensionContext = context
                
        var found = false
        
        outer: for item in context.inputItems as! [NSExtensionItem] {
            if let attachments = item.attachments {
                for itemProvider in attachments {
                    if itemProvider.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
                        itemProvider.loadItem(forTypeIdentifier: UTType.url.identifier, options: nil, completionHandler: { (nssURL, error) in
                            OperationQueue.main.addOperation {
                                if let url = nssURL as? URL {
                                    self.openApp(with: url)
                                } else {
                                    self.doneWithResults(nil)
                                }
                            }
                        })
                        found = true
                        break outer
                    }
                }
            }
        }
        
        if !found {
            self.doneWithResults(nil)
        }
    }
    
    func itemLoadCompletedWithPreprocessingResults(_ javaScriptPreprocessingResults: [String: Any]) {
        // Here, do something, potentially asynchronously, with the preprocessing
        // results.
        
        // In this very simple example, the JavaScript will have passed us the
        // current background color style, if there is one. We will construct a
        // dictionary to send back with a desired new background color style.
        let bgColor: Any? = javaScriptPreprocessingResults["currentBackgroundColor"]
        if bgColor == nil ||  bgColor! as! String == "" {
            // No specific background color? Request setting the background to red.
            self.doneWithResults(["newBackgroundColor": "red"])
        } else {
            // Specific background color is set? Request replacing it with green.
            self.doneWithResults(["newBackgroundColor": "green"])
        }
    }
    
    func doneWithResults(_ resultsForJavaScriptFinalizeArg: [String: Any]?) {
        if let resultsForJavaScriptFinalize = resultsForJavaScriptFinalizeArg {
            // Construct an NSExtensionItem of the appropriate type to return our
            // results dictionary in.
            
            // These will be used as the arguments to the JavaScript finalize()
            // method.
            
            let resultsDictionary = [NSExtensionJavaScriptFinalizeArgumentKey: resultsForJavaScriptFinalize]
            
            let resultsProvider = NSItemProvider(item: resultsDictionary as NSDictionary, typeIdentifier: UTType.propertyList.identifier)
            
            let resultsItem = NSExtensionItem()
            resultsItem.attachments = [resultsProvider]
            
            // Signal that we're complete, returning our results.
            self.extensionContext!.completeRequest(returningItems: [resultsItem], completionHandler: nil)
        } else {
            // We still need to signal that we're done even if we have nothing to
            // pass back.
            self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
        }
        
        // Don't hold on to this after we finished with it.
        self.extensionContext = nil
    }

}
