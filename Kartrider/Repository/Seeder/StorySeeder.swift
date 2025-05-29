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
    static func seedStoriesIfNeeded(context: ModelContext) async {
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
}

