//
//  PlayHistoryRepositoryProtocol.swift
//  Kartrider
//
//  Created by J on 5/30/25.
//

import Foundation
import SwiftData

protocol PlayHistoryRepositoryProtocol {
    func saveTournamentHistory(
        context: ModelContext,
        tournamentId: UUID,
        winner: Candidate,
        matchHistory: [TournamentStepData]
    ) throws
}
