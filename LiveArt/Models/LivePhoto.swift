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
    var livePhoto: PHLivePhoto
    var livePhotoResources: LivePhotoResources
    
    init() {
        self.id = UUID()
    }
}
