//
//  LiveArtApp.swift
//  LiveArt
//
//  Created by GeoWat on 2024/2/27.
//

import SwiftUI
import SwiftData
import TipKit

@main
struct LiveArtApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
            LivePhoto.self,
            Project.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    init() {
        // Configure and load all tips in the app.
        try? Tips.configure([
            .displayFrequency(.immediate),
            .datastoreLocation(.applicationDefault)
        ])
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
