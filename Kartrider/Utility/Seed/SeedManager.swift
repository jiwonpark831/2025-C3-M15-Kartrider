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
        let context = container.mainContext
        let resetKey = "hasSeededOnce"
        
        let isInMemory = container.configurations.first?.isStoredInMemoryOnly == true
        
        // MARK: - 개발용 강제 초기화 트리거 (배포 전 삭제)
        #if DEBUG
        if ProcessInfo.processInfo.environment["RESET_DB"] == "true" { // TODO: - 배포할 때 스키마 RESET_DB = false로 변경
            print("[DEBUG] RESET_DB 환경 변수 감지")
            await resetAll(context: context)
            UserDefaults.standard.removeObject(forKey: resetKey)
        }
        #endif
        
        // isInMemory가 true일 경우 매번 시드
        if isInMemory {
            print("[DEBUG] 인메모리 모드 -> 무조건 시드")
            await performSeeding(context: context)
            return
        }
        
        // 최초 실행 여부 체그 (영구 저장인 경우만)
        let hasSeeded = UserDefaults.standard.bool(forKey: resetKey)
        print("[DEBUG] hasSeededOnce 값: \(hasSeeded)")
        
        guard !hasSeeded else {
            isReady = true
            print("[DEBUG] 이미 시드 완료됨 -> 종료")
            return
        }
        
        print("[INFO] 최초 실행 → 시드 시작")
        await performSeeding(context: context)
        UserDefaults.standard.set(true, forKey: resetKey)
    }
    
    // MARK: - 전체 삭제 (개발용)
    private func resetAll(context: ModelContext) async {
        do {
            try await deleteAll(of: StoryStep.self, context: context)
            try await deleteAll(of: TournamentStep.self, context: context)
            try await deleteAll(of: PlayHistory.self, context: context)
            try await deleteAll(of: ContentMeta.self, context: context)

            try await context.save()
        } catch {
            print("[ERROR] SwiftData 초기화 중 오류 발생: \(error)")
        }
    }
    
    private func deleteAll<T: PersistentModel>(of type: T.Type, context: ModelContext) async throws {
        let all = try context.fetch(FetchDescriptor<T>())
        for item in all {
            context.delete(item)
        }
    }
    
    private func performSeeding(context: ModelContext) async {
        await StorySeeder.seedIfNeeded(context: context)
        await TournamentSeeder.seedIfNeeded(context: context)

        try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5초

        isReady = true
        print("[DEBUG] 시드 완료 → isReady = true")
    }
}
