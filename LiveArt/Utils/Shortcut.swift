//
//  Shortcut.swift
//  LiveArt
//
//  Created by ByteDance on 2/29/24.
//

import Foundation
import UIKit

let ShortcutURLScheme = URL(string: "shortcuts://x-callback-url/run-shortcut?name=Set%20LivePhoto%20Wallpaper")!

func getShortcutURL() -> URL? {
    guard let shortcutURL = Bundle.main.url(forResource: "Set LivePhoto Wallpaper", withExtension: "shortcut") else {
        print("Shortcut file not found in bundle.")
        return nil
    }
    return shortcutURL
}

func invokeShortcut(completion: @escaping (Bool) -> Void) {
    if UIApplication.shared.canOpenURL(ShortcutURLScheme) {
        UIApplication.shared.open(ShortcutURLScheme) { result in
            completion(result)
        }
        completion(true)
    } else {
        completion(false)
    }
}
