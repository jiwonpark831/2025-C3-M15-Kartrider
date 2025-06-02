//
//  TournamentJSONParser.swift
//  Kartrider
//
//  Created by J on 6/2/25.
//

import Foundation
import SwiftData

enum TournamentJSONParser {
    static func loadJSON(named fileName: String) -> Data? {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            print("[ERROR] JSON 파일을 찾을 수 없습니다 - \(fileName)")
            return nil
        }
        return try? Data(contentsOf: url)
    }
    
    static func parseAndInsertTournaments(from jsonData: Data, context: ModelContext) throws {
        let decoder = JSONDecoder()
        let tournamentList = try decoder.decode([TournamentJSON].self, from: jsonData)
        
        for tournamentJSON in tournamentList {
            let meta = ContentMeta(
                title: tournamentJSON.meta.title,
                summary: tournamentJSON.meta.summary,
                type: .tournament,
                hashtags: tournamentJSON.meta.hashtags,
                thumbnailName: tournamentJSON.meta.thumbnailName
            )
            context.insert(meta)
            
            let tournament = Tournament(meta: meta)
            context.insert(tournament)
            
            for candidateData in tournamentJSON.candidates {
                let candidate = Candidate(name: candidateData.name, tournament: tournament)
                tournament.candidates.append(candidate)
                context.insert(candidate)
            }
        }
        
        try context.save()
        print("[DEBUG] 저장된 Tournament 수: \(try context.fetch(FetchDescriptor<Tournament>()).count)")
        print("[DEBUG] 저장된 Candidate 수: \(try context.fetch(FetchDescriptor<Candidate>()).count)")
        print("[DEBUG] 저장된 ContentMeta 수: \(try context.fetch(FetchDescriptor<ContentMeta>()).count)")
    }
}
