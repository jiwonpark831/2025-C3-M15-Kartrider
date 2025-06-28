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
            isStoredInMemoryOnly: true // TODO: - false로 변경
        )
        
        do {
            container = try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
    
    func seedIfNeeded() async {
        let context = container.mainContext
        let resetKey = "hasSeededOnce"
        let isInMemory = container.configurations.first?.isStoredInMemoryOnly == true
        
        #if DEBUG
        if ProcessInfo.processInfo.environment["RESET_DB"] == "true" { // TODO: - 배포할 때 스키마 RESET_DB = false로 변경
            print("[DEBUG] RESET_DB 환경 변수 감지")
            await Seeder<StoryJSON>.deleteAll(context: context)
            await Seeder<TournamentJSON>.deleteAll(context: context)
            UserDefaults.standard.removeObject(forKey: resetKey)
        }
        #endif
        
        if isInMemory {
            print("[DEBUG] 인메모리 모드 -> 무조건 시드")
            await performSeeding(context: context)
            isReady = true
            return
        }
        
        let hasSeeded = UserDefaults.standard.bool(forKey: resetKey)
        print("[DEBUG] hasSeededOnce 값: \(hasSeeded)")
        
        guard !hasSeeded else {
            print("[DEBUG] 이미 시드 완료됨 -> 종료")
            isReady = true
            return
        }
        
        print("[INFO] 최초 실행 → 시드 시작")
        await performSeeding(context: context)
        UserDefaults.standard.set(true, forKey: resetKey)
        isReady = true
    }

    private func performSeeding(context: ModelContext) async {
        await Seeder<StoryJSON>.seedAll(context: context)
        await Seeder<TournamentJSON>.seedAll(context: context)

        try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5초
        isReady = true
        
        print("[DEBUG] 시드 완료 → isReady = true")
    }
}
