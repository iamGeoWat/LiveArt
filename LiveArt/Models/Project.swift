//
//  Project.swift
//  LiveArt
//
//  Created by GeoWat on 2024/2/28.
//

import Foundation
import Photos
import SwiftData

@Model
final class Project {
    enum ProjectType {
        case LiveAlbum
        case UploadedVideo
    }
    let id: UUID
    var currentStep: Int
    let creationDate: String
    var workInProgress: Bool
    var coverPhoto: String?

    var name: String
    let type: ProjectType
    var livePhoto: LivePhoto?
    var liveWallpaper: LivePhoto?
    
    init(name: String, type: ProjectType) {
        self.id = UUID()
        self.currentStep = 1
        self.creationDate = todayDate
        self.workInProgress = false
        self.coverPhoto = nil
        
        self.type = type
        self.name = name
    }
}
