//
//  PlayHistoryRepository.swift
//  Kartrider
//
//  Created by J on 5/30/25.
//

import Foundation
import SwiftData

// 1. TODO: ContentRepository 없애자.
// 2. TODO: 33번 지우고, saveTournamentHistory함수에 tournament라는 매개변수 추가.
// 3. TODO: 이것을 사용할 때, 33번 코드를 활용하자!
// 예시)
// let tournament = try? contentRepository.fetchTournament(by: tournamentId, context: context)
// saveTournamentHistory(... ..., tournament: tournament, ...)

class PlayHistoryRepository: PlayHistoryRepositoryProtocol {
    
    private let contentRepository: ContentRepositoryProtocol
    
    init(contentRepository: ContentRepositoryProtocol = ContentRepository()) {
        self.contentRepository = contentRepository
    }
    
    func saveTournamentHistory(
        context: ModelContext,
        tournamentId: UUID,
        winner: Candidate,
//        tourerments: [],
        matchHistory: [TournamentStepData]
    ) throws {
        guard let tournament = try contentRepository.fetchTournament(by: tournamentId, context: context) else { return }
        
        let history = PlayHistory(content: tournament.meta)
        history.endedAt = Date()
        history.winningCandidateId = winner.id
        context.insert(history)
        
        for step in matchHistory {
            let tournamentStep = TournamentStep(
                round: step.round,
                matchIndex: step.matchIndex,
                candidateAText: step.candidateAText,
                candidateBText: step.candidateBText,
                selectedText: step.selectedText,
                timestamp: step.timestamp,
                history: history
            )
            context.insert(tournamentStep)
        }
        
        try context.save()
    }
}
