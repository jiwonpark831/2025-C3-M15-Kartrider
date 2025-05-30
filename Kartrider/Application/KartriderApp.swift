//
//  KartriderApp.swift
//  Kartrider
//
//  Created by jiwon on 5/27/25.
//

import SwiftData
import SwiftUI

@main
struct KartriderApp: App {

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            ContentMeta.self,
            Story.self,
            StoryNode.self,
            StoryChoice.self,
            EndingCondition.self,
            Tournament.self,
            Candidate.self,
            PlayHistory.self,
            StoryStep.self,
            TournamentStep.self
        ])
        
        let modelConfiguration = ModelConfiguration(
            schema: schema, isStoredInMemoryOnly: true)

        do {
            return try ModelContainer(
                for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            AppNavigationView()
                .task {
                    #if DEBUG
                    let context = sharedModelContainer.mainContext
//                    await StorySeeder.deleteAll(context: context)
//                    await StorySeeder.seed(context: context)
                    await StorySeeder.seedIfNeeded(context: sharedModelContainer.mainContext)
                    #endif
                }
        }
        .modelContainer(sharedModelContainer)
    }}
