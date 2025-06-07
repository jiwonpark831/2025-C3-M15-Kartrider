//
//  TournamentView.swift
//  Kartrider
//
//  Created by J on 6/2/25.
//

import SwiftData
import SwiftUI

struct TournamentView: View {
    @EnvironmentObject private var ttsManager: TTSManager
    @EnvironmentObject private var coordinator: NavigationCoordinator
    @EnvironmentObject private var iosConnectManager: IosConnectManager

    @Environment(\.modelContext) private var context
    @StateObject private var viewModel: TournamentViewModel

    @State private var selectedOption: StoryChoiceOption? = nil
    @State private var decisionIndex = 0
    @State private var decisionTask: Task<Void, Never>? = nil

    let title: String
    let id: UUID

    init(title: String, id: UUID) {
        _viewModel = StateObject(
            wrappedValue: TournamentViewModel(tournamentId: id))
        self.title = title
        self.id = id
    }

    var body: some View {
        NavigationBarWrapper(
            navStyle: .play(title: title),
            onTapLeft: {
                coordinator.pop()
            }
        ) {
            VStack(spacing: 16) { contentBody }.frame(
                maxWidth: .infinity, maxHeight: .infinity
            ).padding(.top, 40)
        }
        .task {
            viewModel.loadTournament(context: context)
            speakCurrentMatch()
        }
        .onChange(of: viewModel.isFinished) { isFinished in
            guard isFinished else { return }
            viewModel.finishTournamentAndSave(context: context)
        }
        .onChange(of: viewModel.currentCandidates?.0.id) { _ in
            selectedOption = nil
            iosConnectManager.timeout = false
            iosConnectManager.isFirstRequest = true
        }
        .onChange(of: iosConnectManager.selectedOption) { newOption in
            guard let option = newOption,
                let (a, b) = viewModel.currentCandidates,
                selectedOption == nil
            else { return }

            decisionTask?.cancel()
            decisionTask = nil

            selectedOption = option
            let selected = option == .a ? a : b
            handleSelection(selected)
        }
        .onChange(of: iosConnectManager.timeout) { newValue in
            handleTimeout(newValue)
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
                iosConnectManager.sendStageEndingTTS()
                guard let name = viewModel.winner?.name else { return }
                await ttsManager.stop()
                try? await Task.sleep(nanoseconds: 300_000_000)
                await ttsManager.speakSequentially("최종 우승자는 \(winner.name)입니다")
                iosConnectManager.sendStageEndingTimer()
            }
        } else if let (a, b) = viewModel.currentCandidates {
            TournamentMatchView(
                roundDescription: viewModel.currentRoundDescription,
                a: a.name,
                b: b.name,
                onSelectA: {
                    selectedOption = .a
                    handleSelection(a)
                },
                onSelectB: {
                    selectedOption = .b
                    handleSelection(b)
                },
                buttonDisabled: ttsManager.state == .playing,
                selectedOption: selectedOption
            )
        } else {
            ProgressView()
        }
    }

    private var statusIndicator: some View {
        Text(ttsManager.state == .playing ? "읽는 중..." : "정지됨")
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
            iosConnectManager.sendChoiceInterrupt()
            await speakSelectedChoice(candidate)
            try? await Task.sleep(nanoseconds: 200_000_000)

            viewModel.select(candidate)
            decisionIndex += 1
            speakCurrentMatch()
        }
    }

    private func speakCurrentMatch() {
        guard let (a, b) = viewModel.currentCandidates else { return }

        decisionTask?.cancel()

        iosConnectManager.timeout = false
        iosConnectManager.isFirstRequest = true

        decisionTask = Task {
            iosConnectManager.sendStageDecisionWithFirstTTS(
                decisionIndex)
            await ttsManager.speakSequentially(
                viewModel.currentRoundDescription)
            await ttsManager.speakSequentially("A. \(a.name)")
            await ttsManager.speakSequentially("B. \(b.name)")
            iosConnectManager.sendStageDecisionWithFirstTimer(
                decisionIndex)
        }
    }

    private func playSecondTTS() {
        guard let (a, b) = viewModel.currentCandidates else { return }
        decisionTask?.cancel()

        let texts = [
            "선택지가 다시 한번 재생됩니다",
            "A. \(a.name)",
            "B. \(b.name)",
        ]

        decisionTask = Task {
            iosConnectManager.sendStageDecisionWithSecTTS(decisionIndex)
            for text in texts { await ttsManager.speakSequentially(text) }
            let totalDelay =
                texts.map { estimateDuration(for: $0) }.reduce(0, +)
                + 200_000_000
            try? await Task.sleep(nanoseconds: totalDelay)
            iosConnectManager.sendStageDecisionWithSecTimer(decisionIndex)
        }
    }

    private func estimateDuration(for text: String) -> UInt64 {
        let seconds = Double(text.count) * 0.1
        return UInt64(seconds * 1_000_000_000)
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

    private func handleTimeout(_ newValue: Bool?) {
        let isTimeout = newValue == true
        let sameIndex = iosConnectManager.decisionIndex == decisionIndex
        let noSelection = selectedOption == nil

        guard isTimeout, sameIndex, noSelection else { return }

        if iosConnectManager.isFirstRequest {
            playSecondTTS()
        } else {
            if let (aCandidate, _) = viewModel.currentCandidates {
                selectedOption = .a
                handleSelection(aCandidate)
            }
        }
        iosConnectManager.timeout = false
    }

}

#Preview {
    TournamentView(title: "타이틀 확인중", id: UUID())
}
