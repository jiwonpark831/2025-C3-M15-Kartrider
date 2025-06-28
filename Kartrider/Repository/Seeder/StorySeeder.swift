//
//  StorySeeder.swift
//  Kartrider
//
//  Created by J on 5/29/25.
//

import Foundation
import SwiftData

// TODO: Generic + Protocol로 리팩토링
// TODO: small Camel Case로 바꾸세요!
// TODO: 객체로 바꾸세요!
// TODO: 1. StorySeeder, TournamentSeeder를 합친다. -> Seeder로 통합
// TODO: 2. StoryJSON, TournamentJSON -> 프로토콜로 통합
// TODO: 3. StoryJSON, TournamentJSON 따라 로직을 분기한다! (분기하는 로직도 extension으로 빼면 좋을 것 같음!)
@MainActor
struct StorySeeder {
    // TODO: 동시성 문제가 있을 것으로 예상 -> 수정, 다 동기적으로 처리해도 좋을 것 같음
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
    
    // MARK: 개행 왜 이따구죠?
    static func seedIfNeeded(context: ModelContext) async {
        await deleteAll(context: context)
        await seed(context: context)
        print("[INFO] 인메모리 모드 - 시드 완료")
        

        
    }
    
    static func seed(context: ModelContext) async {
        // TODO: Constant 파일로 분리
        guard let jsonData = StoryJSONParser.loadJSON(named: "story_dummy") else {
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

