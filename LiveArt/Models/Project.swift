//
//  Project.swift
//  LiveArt
//
//  Created by GeoWat on 2024/2/28.
//

import Foundation
import Photos
import SwiftData
import _PhotosUI_SwiftUI
import SwiftUI

@Model
final class Project: ObservableObject {
    
    let id: UUID
    var currentStep: Int
    let creationDate: String
    var workInProgress: Bool
    var coverPhoto: URL?

    var name: String
    let type: ProjectType
    var livePhoto: LivePhoto?
    var liveWallpaper: LivePhoto?
    var rawVideoFileURL: URL?
    
    init(name: String, type: ProjectType) {
        self.id = UUID()
        self.currentStep = 1
        self.creationDate = todayDate
        self.workInProgress = true
        self.coverPhoto = nil
        
        self.type = type
        self.name = name
    }
}
