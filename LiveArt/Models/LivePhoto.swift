//
//  LivePhoto.swift
//  LiveArt
//
//  Created by GeoWat on 2024/2/28.
//

import Foundation
import Photos
import SwiftData

typealias LivePhotoResources = (pairedImage: URL, pairedVideo: URL)

@Model
final class LivePhoto {
    let id: UUID
    
    var pairedImage: URL
    var pairedVideo: URL
    
    init(pairedImage: URL, pairedVideo: URL) {
        self.id = UUID()
        self.pairedImage = pairedImage
        self.pairedVideo = pairedVideo
    }
}
