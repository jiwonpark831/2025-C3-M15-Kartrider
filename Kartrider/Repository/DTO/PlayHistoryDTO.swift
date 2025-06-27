//
//  PlayHistoryDTO.swift
//  Kartrider
//
//  Created by J on 6/4/25.
//

import Foundation

// MARK: 파일이름이랑 구조체랑 이름 다름.
struct TournamentStepData: Identifiable {
    let id = UUID()
    var round: Int
    var matchIndex: Int
    var candidateAText: String
    var candidateBText: String
    var selectedText : String
    var timestamp: Date
}
