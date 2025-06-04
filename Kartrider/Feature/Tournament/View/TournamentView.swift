//
//  TournamentView.swift
//  Kartrider
//
//  Created by J on 6/2/25.
//

import SwiftUI
import SwiftData

struct TournamentView: View {
    @EnvironmentObject private var ttsManager: TTSManager
    @EnvironmentObject private var coordinator: NavigationCoordinator
    @Environment(\.modelContext) private var context
    @StateObject private var viewModel: TournamentViewModel
    
    let title: String
    let id: UUID
    
    init(title: String, id: UUID) {
        _viewModel = StateObject(wrappedValue: TournamentViewModel(tournamentId: id))
        self.title = title
        self.id = id
    }
    
    var body: some View {
        NavigationBarWrapper(
            navStyle: .play(title: title),
            onTapLeft: { coordinator.pop() }
        ) {
            VStack(spacing: 16) {
                contentBody
                statusIndicator
                retryButton
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.top, 40)
        }
        .task {
            viewModel.loadTournament(context: context)
            speakCurrentMatch()
        }
        .onChange(of: viewModel.isFinished) { isFinished in
            guard isFinished else { return }
            viewModel.finishTournamentAndSave(context: context)
        }
    }
    
    // MARK: - View Sections
    
    @ViewBuilder
    private var contentBody: some View {
        if viewModel.isFinished, let winner = viewModel.winner {
            TournamentResultView(winner: winner.name) {
                coordinator.popToRoot()
            }
            .task(id: viewModel.winner?.id) {
                guard let name = viewModel.winner?.name else { return }
                await ttsManager.stop()
                try? await Task.sleep(nanoseconds: 300_000_000)
                await ttsManager.speakSequentially("최종 우승자는 \(winner.name)입니다")
            }
        } else if let (a, b) = viewModel.currentCandidates {
            TournamentMatchView(
                roundDescription: viewModel.currentRoundDescription,
                a: a.name,
                b: b.name,
                onSelectA: { handleSelection(a) },
                onSelectB: { handleSelection(b) },
                buttonDisabled: ttsManager.isSpeaking
            )
        } else {
            ProgressView()
        }
    }
    
    private var statusIndicator: some View {
        Text(ttsManager.isSpeaking ? "읽는 중..." : "정지됨")
            .font(.caption)
            .foregroundColor(.gray)
    }
    
    private var retryButton: some View {
        Button("선택지 다시 듣기", action: speakOnlyChoices)
            .padding(.top, 8)
    }
}

extension TournamentView {
    // MARK: - TTS Helpers
    private func handleSelection(_ candidate: Candidate) {
        
        Task {
            await ttsManager.stop()
            await speakSelectedChoice(candidate)
            try? await Task.sleep(nanoseconds: 200_000_000)
            
            viewModel.select(candidate)
            speakCurrentMatch()
        }
    }
    
    private func speakCurrentMatch() {
        guard let (a, b) = viewModel.currentCandidates else { return }
        Task {
            await ttsManager.speakSequentially(viewModel.currentRoundDescription)
            await ttsManager.speakSequentially("A. \(a.name)")
            await ttsManager.speakSequentially("B. \(b.name)")
        }
    }
    
    private func speakOnlyChoices() {
        guard let (a, b) = viewModel.currentCandidates else { return }
        Task {
            await ttsManager.speakSequentially("A. \(a.name)")
            await ttsManager.speakSequentially("B. \(b.name)")
        }
    }
    
    private func speakSelectedChoice(_ candidate: Candidate) async {
        await ttsManager.speakSequentially("\(candidate.name) 선택")
    }
}

#Preview {
    TournamentView(title: "타이틀 확인중", id: UUID())
}
