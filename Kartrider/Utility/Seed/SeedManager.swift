//
//  SeedManager.swift
//  Kartrider
//
//  Created by J on 6/7/25.
//

import Foundation
import SwiftData

@MainActor
class SeedManager: ObservableObject {
    @Published var isReady = false
    let container: ModelContainer
    
    init() {
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
            TournamentStep.self,
        ])
        
        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true // TODO: - 나중에 false로 변경
        )
        
        do {
            container = try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
    func seedIfNeeded() async {
//        #if DEBUG
        let context = container.mainContext
        
        let startTime = Date()
        
        await StorySeeder.seedIfNeeded(context: context)
        await TournamentSeeder.seedIfNeeded(context: context)
        
        let elapsed = Date().timeIntervalSince(startTime)
        let delay = max(0, 1.5 - elapsed)
        
        if delay > 0 {
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        }
//        #endif
        isReady = true
    }
}
