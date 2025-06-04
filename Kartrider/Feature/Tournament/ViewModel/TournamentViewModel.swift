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
    @Published var matchHistory: [TournamentStepData] = []
    @Published var isSpeaking = false
    
    private let contentRepository: ContentRepositoryProtocol
    private let historyRepository: PlayHistoryRepositoryProtocol
    private let tournamentId: UUID
    private var tournament: Tournament?
    private var nextRoundCandidates: [Candidate] = []
    private var rounds: [[Candidate]] = []
    private var currentRoundIndex = 0 // 지금 몇 라운드인지 ex. 8강, 4강, 결승
    private var currentMatchIndex = 0 // 지금 라운드에서 몇번째 매치인지
    
    var ttsManager = TTSManager()
    
    var currentRoundDescription: String {
        guard rounds.indices.contains(currentRoundIndex) else { return "" }
        let count = rounds[currentRoundIndex].count
        let roundText : String = (count == 2) ? "결승" : "\(count)강"
        let matchNumber = currentMatchIndex + 1
        let totalMatches = count / 2
        return "\(roundText)\n\(totalMatches)개의 경기 중 \(matchNumber)번째 경기"
    }
    
    init(
        tournamentId: UUID,
        contentRepository: ContentRepositoryProtocol = ContentRepository(),
        historyRepository: PlayHistoryRepositoryProtocol = PlayHistoryRepository()
    ) {
        self.tournamentId = tournamentId
        self.contentRepository = contentRepository
        self.historyRepository = historyRepository
        ttsManager.didSpeakingStateChanged = { [weak self] speaking in
            DispatchQueue.main.async {
                self?.isSpeaking = speaking
            }
        }
    }
    
    func loadTournament(context: ModelContext) {
        do {
            guard let tournament = try contentRepository.fetchTournament(by: tournamentId, context: context) else {
                print("[ERROR] 토너먼트 찾을 수 없음")
                return
            }
            self.tournament = tournament
            let shuffled = tournament.candidates.shuffled()
            rounds = [shuffled]
            isFinished = false
            winner = nil
            currentRoundIndex = 0
            currentMatchIndex = 0
            matchHistory = []
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
        guard let (a, b) = currentCandidates else { return }
        
        // 기록 저장
        let step = TournamentStepData(
            round: rounds[currentRoundIndex].count,
            matchIndex: currentMatchIndex,
            candidateAText: a.name,
            candidateBText: b.name,
            selectedText: selected.name,
            timestamp: Date()
        )
        matchHistory.append(step)
        
        nextRoundCandidates.append(selected)
        currentMatchIndex += 1
        prepareNextMatch()
    }

    
    private func makeNextRound(from round: [Candidate]) -> [Candidate] {
        return round
    }
    
    func finishTournamentAndSave(context: ModelContext) {
        guard let winner = winner else { return }
        do {
            try historyRepository.saveTournamentHistory(
                context: context,
                tournamentId: tournamentId,
                winner: winner,
                matchHistory: matchHistory
            )
        } catch {
            print("[ERROR] 토너먼트 히스토리 저장 실패 : \(error)")
        }
    }
    
    
}
