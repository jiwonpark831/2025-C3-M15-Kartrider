//
//  TournamentViewModel.swift
//  Kartrider
//
//  Created by J on 6/2/25.
//

import Foundation
import SwiftData

class TournamentViewModel: ObservableObject {
    
    @Published var currentCandidates: (Candidate, Candidate)?
    @Published var isFinished = false
    @Published var winner: Candidate?
    
    private let repository: ContentRepositoryProtocol
    private let tournamentId: UUID
    
    private var nextRoundCandidates: [Candidate] = []
    private var rounds: [[Candidate]] = []
    private var currentRoundIndex = 0 // 지금 몇 라운드인지 ex. 8강, 4강, 결승
    private var currentMatchIndex = 0 // 지금 라운드에서 몇번째 매치인지
    
    var currentRoundDescription: String {
        guard rounds.indices.contains(currentRoundIndex) else { return "" }
        let count = rounds[currentRoundIndex].count
        let roundText : String
        
        switch count {
        case 2: roundText = "결승"
        default: roundText = "\(count)강"
        }
        
        
        let matchNumber = currentMatchIndex + 1
        let totalMatches = count / 2
        
        return "\(roundText)\n\(totalMatches)개의 경기 중 \(matchNumber)번째 경기"
    }
    
    init(tournamentId: UUID, repository: ContentRepositoryProtocol = ContentRepository()) {
        self.tournamentId = tournamentId
        self.repository = repository
    }
    
    func loadTournament(context: ModelContext) {
        do {
            guard let tournament = try repository.fetchTournament(by: tournamentId, context: context) else {
                print("[ERROR] 토너먼트 찾을 수 없음")
                return
            }
            
            let shuffled = tournament.candidates.shuffled()
            rounds = [shuffled]
            isFinished = false
            winner = nil
            currentRoundIndex = 0
            currentMatchIndex = 0
            
            prepareNextMatch()
        } catch {
            print("[ERROR] 토너먼트 로딩 실패 : \(error)")
        }
    }
    
    func prepareNextMatch() {
        let currentRound = rounds[currentRoundIndex]

        guard currentMatchIndex * 2 + 1 < currentRound.count else {
            // 현재 라운드 끝났으면
            if nextRoundCandidates.count == 1 {
                winner = nextRoundCandidates.first
                isFinished = true
                currentCandidates = nil
            } else {
                // 다음 라운드 준비
                rounds.append(nextRoundCandidates)
                currentRoundIndex += 1
                currentMatchIndex = 0
                nextRoundCandidates = []
                prepareNextMatch()
            }
            return
        }

        let a = currentRound[currentMatchIndex * 2]
        let b = currentRound[currentMatchIndex * 2 + 1]
        currentCandidates = (a, b)
    }
    
    func select(_ selected: Candidate) {
        nextRoundCandidates.append(selected)
        currentMatchIndex += 1
        prepareNextMatch()
    }

    
    private func makeNextRound(from round: [Candidate]) -> [Candidate] {
        return round
    }
    
    
    
}
