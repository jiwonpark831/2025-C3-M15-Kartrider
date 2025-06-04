//
//  PlayHistoryRepository.swift
//  Kartrider
//
//  Created by J on 5/30/25.
//

import Foundation
import SwiftData

class PlayHistoryRepository: PlayHistoryRepositoryProtocol {
    
    private let contentRepository: ContentRepositoryProtocol
    
    init(contentRepository: ContentRepositoryProtocol = ContentRepository()) {
        self.contentRepository = contentRepository
    }
    
    func saveTournamentHistory(
        context: ModelContext,
        tournamentId: UUID,
        winner: Candidate,
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
