//
//  File.swift
//
//
//  Created by GeoWat on 2024/2/12.
//

import Foundation
import Photos
import UIKit
import AVFoundation

class ViewModel: ObservableObject {
    @Published var shortcutModel = ShortcutModel()
    @Published var projects: [ProjectModel] = []
    
    init() {
        loadProjects()
        loadShortcut()
    }
    
    func loadProjects() {
        projects = [
            ProjectModel(name: "sos", type: .LiveAlbum, creationDate: "February 24, 2024", coverPhoto: "sos_photo", currentStep: 2, workInProgress: true, livePhoto: nil),
            ProjectModel(name: "speak_now", type: .LiveAlbum, creationDate: "February 24, 2024", coverPhoto: "speak_now_photo", currentStep: 2, workInProgress: true, livePhoto: nil),
            ProjectModel(name: "coffee", type: .LiveAlbum, creationDate: "February 24, 2024", coverPhoto: "coffee", currentStep: 2, workInProgress: true, livePhoto: nil),
            ProjectModel(name: "can", type: .LiveAlbum, creationDate: "February 24, 2024", coverPhoto: "can", currentStep: 2, workInProgress: true, livePhoto: nil),
            ProjectModel(name: "New Project", type: .LiveAlbum, creationDate: "February 25, 2024", coverPhoto: nil, currentStep: 1, workInProgress: true, livePhoto: nil),
        ]
    }
    
    func addProject(_ project: ProjectModel) {
        projects.append(project)
    }
    
    // Add or update existing methods as needed
    func updateProject<T: Equatable>(id: UUID, property: WritableKeyPath<ProjectModel, T>, newValue: T) {
        if let index = projects.firstIndex(where: { $0.id == id }) {
            // Check if the new value is different to avoid unnecessary updates
            if projects[index][keyPath: property] != newValue {
                projects[index][keyPath: property] = newValue
                objectWillChange.send()
            }
        }
    }
    
    
}

