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
            print("[INFO] 모든 SwiftData 데이터 삭제 완료")
        } catch {
            print("[ERROR] 데이터 삭제 실패: \(error)")
        }
    }
    
    
    static func seedIfNeeded(context: ModelContext) async {
        await deleteAll(context: context)
        await seed(context: context)
        print("[INFO] 인메모리 모드 - 시드 완료")
        

        
    }
    
    static func seed(context: ModelContext) async {
        guard let jsonData = StoryJSONParser.loadJSON(named: "dummy_story") else {
            print("[ERROR] JSON 파일 로드 실패")
            return
        }
        
        do {
            try StoryJSONParser.parseAndInsertStories(from: jsonData, context: context)
            print("[INFO] 스토리 데이터 시드 완료")
        } catch {
            print("[ERROR] 파싱 실패: \\(error)")
        }
    }
    
    static func printStoryCount(context: ModelContext) async {
        do {
            let count = try context.fetch(FetchDescriptor<Story>()).count
            print("[INFO] 현재 저장된 Story 개수: \(count)")
        } catch {
            print("[ERROR] Story 개수 확인 실패: \(error)")
        }
    }
}

