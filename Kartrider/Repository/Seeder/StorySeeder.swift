//
//  StorySeeder.swift
//  Kartrider
//
//  Created by J on 5/29/25.
//

import Foundation
import SwiftData

@MainActor
struct StorySeeder {
    static let seedKey = "hasSeededStories"
    
    static func deleteAll(context: ModelContext) async {
        do {
            try context.delete(model: ContentMeta.self)
            try context.delete(model: Story.self)
            try context.delete(model: StoryNode.self)
            try context.delete(model: StoryChoice.self)
            try context.delete(model: EndingCondition.self)
            try context.delete(model: Tournament.self)
            try context.delete(model: Candidate.self)
            try context.delete(model: PlayHistory.self)
            try context.delete(model: StoryStep.self)
            try context.delete(model: TournamentStep.self)
            
            try await context.save()
            print("[SUCCESS] 모든 SwiftData 데이터 삭제 완료")
        } catch {
            print("[ERROR] 데이터 삭제 실패: \(error)")
        }
    }
    
    
    static func seedIfNeeded(context: ModelContext) async {
        let hasSeeded = UserDefaults.standard.bool(forKey: seedKey)
        guard !hasSeeded else {
            print("[SUCCESS] 이미 시딩 완료됨. 건너뜀.")
            await printStoryCount(context: context)
            return
        }
        
        do {
            try await deleteAll(context: context)
            try await seed(context: context)
            
            UserDefaults.standard.set(true, forKey: seedKey)
            print("[SUCCESS] 시딩 완료 및 UserDefaults 설정됨")
        } catch {
            print("[ERROR] 시딩 실패: \(error)")
        }
    }
    
    static func seed(context: ModelContext) async {
        guard let jsonData = StoryJSONParser.loadJSON(named: "dummy_story") else {
            print("[ERROR] JSON 파일 로드 실패")
            return
        }
        
        do {
            try StoryJSONParser.parseAndInsertStories(from: jsonData, context: context)
            print("[SUCCESS] 스토리 데이터 시드 완료")
        } catch {
            print("[ERROR] 파싱 실패: \\(error)")
        }
    }
    static func printStoryCount(context: ModelContext) async {
        do {
            let count = try context.fetch(FetchDescriptor<Story>()).count
            print("[DEBUG] 현재 저장된 Story 개수: \(count)")
        } catch {
            print("[ERROR] Story 개수 확인 실패: \(error)")
        }
    }
}

