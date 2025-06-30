//
//  TournamentView.swift
//  Kartrider
//
//  Created by J on 6/2/25.
//

import SwiftData
import SwiftUI

struct TournamentView: View {
    // TODO: 객체 제거 및 ViewModel로 분리
    @EnvironmentObject private var ttsManager: TTSManager
    @EnvironmentObject private var coordinator: NavigationCoordinator

    @Environment(\.modelContext) private var context
    @StateObject private var tournamentViewModel: TournamentViewModel

    // Gigi ->  이거 뷰모델로 옮김
    //    @State private var selectedOption: StoryChoiceOption? = nil
    //    @State private var decisionIndex = 0
    //    @State private var decisionTask: Task<Void, Never>? = nil

    // TODO: ViewModel로 분리
    let title: String
    let id: UUID

    // TODO: init 제거
    init(content: ContentMeta) {
        _tournamentViewModel = StateObject(
            wrappedValue: TournamentViewModel(content: content))
        self.title = content.title
        self.id = content.id
    }

    var body: some View {
        NavigationBarWrapper(
            navStyle: .play(title: title),
            onTapLeft: {
                coordinator.pop()
            }
        ) {
            VStack(spacing: 16) {
                Divider()

                if tournamentViewModel.isFinished,
                    let winner = tournamentViewModel.winner
                {
                    TournamentResultView(winner: winner.name) {
                        coordinator.popToRoot()
                    }
                    .task(id: tournamentViewModel.winner?.id) {
                        tournamentViewModel.connectManager.sendStageEndingTTS()
                        guard let name = tournamentViewModel.winner?.name else {
                            return
                        }
                        // TODO: ttsManager.stop : Async함수 아님
                        await ttsManager.stop()
                        try? await Task.sleep(nanoseconds: 300_000_000)
                        await ttsManager.speakSequentially(
                            "최종 우승자는 \(winner.name)입니다")
                        tournamentViewModel.connectManager
                            .sendStageEndingTimer()
                    }
                    // TODO: a, b 이렇게 쓰지 말고, 알기 쉬운 변수명으로 변경
                } else if let (a, b) = tournamentViewModel.currentCandidates {
                    TournamentMatchView(
                        roundDescription: tournamentViewModel
                            .currentRoundDescription,
                        a: a.name,
                        b: b.name,
                        onSelectA: {
                            tournamentViewModel.selectedOption = .a
                            tournamentViewModel.handleSelection(a)
                        },
                        onSelectB: {
                            tournamentViewModel.selectedOption = .b
                            tournamentViewModel.handleSelection(b)
                        },
                        buttonDisabled: ttsManager.state == .playing,
                        selectedOption: tournamentViewModel.selectedOption
                    )
                } else {
                    ProgressView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .task {
            tournamentViewModel.loadTournament(context: context)
            tournamentViewModel.speakCurrentMatch()
        }
        // TODO: onChange 제거 : ViewModel로 분리
        .onChange(of: tournamentViewModel.isFinished) { isFinished in
            guard isFinished else { return }
            tournamentViewModel.finishTournamentAndSave(context: context)
        }
        //         TODO: onChange 제거 : ViewModel로 분리
        .onChange(of: tournamentViewModel.currentCandidates?.0.id) { _ in
            tournamentViewModel.connectManager.selectedOption = nil
            tournamentViewModel.connectManager.isTimeout = false
            tournamentViewModel.connectManager.isFirstRequest = true
        }
    }
}

//// TODO: ViewModel로 분리
////Gigi- 이것도 뷰모델로옮김
//extension TournamentView {
//    // MARK: - TTS Helpers
//
//        private func handleSelection(_ candidate: Candidate) {
//
//            Task {
//                // TODO: ttsManager.stop : Async함수 아님
//                await ttsManager.stop()
//                iosConnectManager.sendChoiceInterrupt()
//                await speakSelectedChoice(candidate)
//                try? await Task.sleep(nanoseconds: 200_000_000)
//
//                viewModel.select(candidate)
//                decisionIndex += 1
//                speakCurrentMatch()
//            }
//        }
//
//        private func speakCurrentMatch() {
//            guard let (a, b) = viewModel.currentCandidates else { return }
//
//            decisionTask?.cancel()
//
//            iosConnectManager.timeout = false
//            iosConnectManager.isFirstRequest = true
//
//            decisionTask = Task {
//                iosConnectManager.sendStageDecisionWithFirstTTS(
//                    decisionIndex)
//                await ttsManager.speakSequentially(
//                    viewModel.currentRoundDescription)
//                await ttsManager.speakSequentially("A. \(a.name)")
//                await ttsManager.speakSequentially("B. \(b.name)")
//                iosConnectManager.sendStageDecisionWithFirstTimer(
//                    decisionIndex)
//            }
//        }
//
//        private func playSecondTTS() {
//            guard let (a, b) = viewModel.currentCandidates else { return }
//            decisionTask?.cancel()
//
//            let texts = [
//                "선택지가 다시 한번 재생됩니다",
//                "A. \(a.name)",
//                "B. \(b.name)",
//            ]
//
//            decisionTask = Task {
//                iosConnectManager.sendStageDecisionWithSecTTS(decisionIndex)
//                for text in texts { await ttsManager.speakSequentially(text) }
//                let totalDelay =
//                    texts.map { estimateDuration(for: $0) }.reduce(0, +)
//                    + 200_000_000
//                try? await Task.sleep(nanoseconds: totalDelay)
//                iosConnectManager.sendStageDecisionWithSecTimer(decisionIndex)
//            }
//        }
//
//        private func estimateDuration(for text: String) -> UInt64 {
//            let seconds = Double(text.count) * 0.1
//            return UInt64(seconds * 1_000_000_000)
//        }
//
//        private func speakOnlyChoices() {
//            guard let (a, b) = viewModel.currentCandidates else { return }
//            Task {
//                await ttsManager.speakSequentially("A. \(a.name)")
//                await ttsManager.speakSequentially("B. \(b.name)")
//            }
//        }
//
//        private func speakSelectedChoice(_ candidate: Candidate) async {
//            await ttsManager.speakSequentially("\(candidate.name) 선택")
//        }
//
//        private func handleTimeout(_ newValue: Bool?) {
//            let isTimeout = newValue == true
//            let sameIndex = iosConnectManager.decisionIndex == decisionIndex
//            let noSelection = selectedOption == nil
//
//            guard isTimeout, sameIndex, noSelection else { return }
//
//            if iosConnectManager.isFirstRequest {
//                playSecondTTS()
//            } else {
//                if let (aCandidate, _) = viewModel.currentCandidates {
//                    selectedOption = .a
//                    handleSelection(aCandidate)
//                }
//            }
//            iosConnectManager.timeout = false
//        }
//
//}

#Preview {

    let sample = ContentMeta(
        title: "눈 떠보니 내가 T1 페이커?!",
        summary: "2025 월즈가 코 앞인데 아이언인 내가 어느날 눈 떠보니 페이커 몸에 들어와버렸다.",
        type: .story,
        hashtags: ["빙의", "LOL", "고트"],
        thumbnailName: nil
    )

    TournamentView(content: sample)
}
