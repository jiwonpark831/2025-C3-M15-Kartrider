//
//  TournamentSeeder.swift
//  Kartrider
//
//  Created by J on 6/2/25.
//

import Foundation
import SwiftData

@MainActor
struct TournamentSeeder {
    static func seedIfNeeded(context: ModelContext) async {
        await seed(context: context)
        print("[INFO] Tournament 시드 완료")
    }

    static func seed(context: ModelContext) async {
        guard let jsonData = TournamentJSONParser.loadJSON(named: "dummy_tournament") else {
            print("[ERROR] Tournament JSON 파일 로드 실패")
            return
        }

        do {
            try TournamentJSONParser.parseAndInsertTournaments(from: jsonData, context: context)
            print("[INFO] Tournament 데이터 시드 완료")
        } catch {
            print("[ERROR] Tournament 파싱 실패: \(error)")
        }
    }

    static func printCandidateCount(context: ModelContext) async {
        do {
            let count = try context.fetch(FetchDescriptor<Candidate>()).count
            print("[INFO] 현재 저장된 Candidate 수: \(count)")
        } catch {
            print("[ERROR] Candidate 수 확인 실패: \(error)")
        }
    }
}
