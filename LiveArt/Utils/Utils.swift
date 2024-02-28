//
//  Utils.swift
//  LiveArt
//
//  Created by GeoWat on 2024/2/28.
//

import Foundation

let shortcutURLScheme = URL(string: "shortcuts://x-callback-url/run-shortcut?name=Set%20LivePhoto%20Wallpaper")

var todayDate: String {
    let today = Date()
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .long
    dateFormatter.locale = Locale(identifier: "en_US")
    return dateFormatter.string(from: today)
}
