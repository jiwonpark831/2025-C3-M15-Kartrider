//
//  TournamentStep.swift
//  Kartrider
//
//  Created by J on 5/29/25.
//

import Foundation
import SwiftData

@Model
class TournamentStep {
    var round: Int
    var candidateAId: UUID
    var candidateBId: UUID
    var candidateAText: String
    var candidateBText: String
    var selectedCandidateId: UUID
    var selectedText: String
    var timestamp: Date = Date()

    @Relationship var history: PlayHistory

    init(round: Int, candidateAId: UUID, candidateBId: UUID, candidateAText: String, candidateBText: String, selectedCandidateId: UUID, selectedText: String, timestamp: Date, history: PlayHistory) {
        self.round = round
        self.candidateAId = candidateAId
        self.candidateBId = candidateBId
        self.candidateAText = candidateAText
        self.candidateBText = candidateBText
        self.selectedCandidateId = selectedCandidateId
        self.selectedText = selectedText
        self.timestamp = timestamp
        self.history = history
    }
}

