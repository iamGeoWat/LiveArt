//
//  PreviewSupport.swift
//  LiveArt
//
//  Created by GeoWat on 2024/3/1.
//

import Foundation
import SwiftData

struct SampleProject {
    static var contents: [Project] = [
        Project(type: .LiveAlbum),
        Project(type: .UploadedVideo),
    ]
}

@MainActor
let previewContainer: ModelContainer = {
    do {
        let container = try ModelContainer(
            for: Project.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let modelContext = container.mainContext
        if try modelContext.fetch(FetchDescriptor<Project>()).isEmpty {
            SampleProject.contents.forEach { container.mainContext.insert($0) }
        }
        return container
    } catch {
        fatalError("Failed to create container")
    }
}()

func printDocumentDirectoryPath() {
    if let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
        print("Document Directory Path: \(path)")
    }
}
