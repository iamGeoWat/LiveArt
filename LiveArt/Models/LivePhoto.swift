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
    
    @Transient var livePhoto: PHLivePhoto?
    var pairedImage: URL
    var pairedVideo: URL
    
    init(pairedImage: URL, pairedVideo: URL, livePhoto: PHLivePhoto? = nil) {
        self.id = UUID()
        self.livePhoto = livePhoto
        self.pairedImage = pairedImage
        self.pairedVideo = pairedVideo
    }
}
