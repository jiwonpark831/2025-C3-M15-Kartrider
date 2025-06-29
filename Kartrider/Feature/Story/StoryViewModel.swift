//
//  StoryViewModel.swift
//  Kartrider
//
//  Created by J on 5/31/25.
//
import Foundation
import SwiftData

class StoryViewModel: ObservableObject {
    let content: ContentMeta
    let startNodeId: String
    private let contentRepository: ContentRepositoryProtocol
    private var lastToggleTime: Date = .distantPast

    // TODO: iOSConnectManager 사용 안함 (여기서 생성한 적이 없음)
    @Published var iosConnectManager: IosConnectManager?

    @Published var isLoading: Bool = true
    @Published var errorMessage: String?
    @Published var currentNode: StoryNode?
    @Published var isSequenceInProgress = false
    @Published var selectedPath: [StoryChoiceOption] = []
    @Published var endingId: String = ""
    @Published var isSpeaking = false
    @Published var isTogglingTTS = false
    @Published var isTransitioningTTS = false

    @Published var decisionIndex = 0
    private var secPlayed = false
    private var decisionTask: Task<Void, Never>? = nil

    var ttsManager = TTSManager()

    init(
        repository: ContentRepositoryProtocol = ContentRepository(),
        content: ContentMeta
    ) {
        self.contentRepository = repository
        self.content = content
        self.startNodeId = content.story?.startNodeId ?? ""

        ttsManager.didSpeakingStateChanged = { [weak self] speaking in
            DispatchQueue.main.async {
                self?.isSpeaking = speaking
                self?.isTogglingTTS = false
            }
        }

    }

    @MainActor
    func loadInitialNode(context: ModelContext) async {
        isLoading = true
        errorMessage = nil
        do {
            if let story = try contentRepository.fetchStory(
                by: content.title, context: context),
                let node = story.nodes.first(where: { $0.id == startNodeId })
            {
                currentNode = node
                await handleStoryNode(node, context: context)
            } else {
                errorMessage = "해당 스토리를 찾을 수 없습니다"
            }
        } catch {
            errorMessage = "스토리 로딩 실패: \(error.localizedDescription)"
        }
        isLoading = false
    }

    func goToNextNode(from currentNode: StoryNode) {
        guard let nextId = currentNode.nextId,
              let story = currentNode.story,
              let nextNode = story.nodes.first(where: {$0.id == nextId}) else {
            errorMessage = "다음 스토리 노드를 찾을 수 없습니다"
            return
        }

        Task { @MainActor in
            self.currentNode = nextNode
        }
    }

    func selectChoice(toId: String) {
        guard let currentNode = currentNode,
              let story = currentNode.story,
              let nextNode = story.nodes.first(where: { $0.id == toId }) else {
            errorMessage = "선택한 노드를 찾을 수 없습니다"
            return
        }

        if let choice = currentNode.choiceA, choice.toId == toId {
            selectedPath.append(.a)
        } else if let choice = currentNode.choiceB, choice.toId == toId {
            selectedPath.append(.b)
        }
        print("[INFO] 선택한 길: \(selectedPath)")

        self.currentNode = nextNode
        self.decisionIndex += 1
    }

    @MainActor
    func handleStoryNode(_ node: StoryNode, context: ModelContext) async {
        //        await ttsManager.speakSequentially(node.text)
        self.isSequenceInProgress = true

        if node.type == .decision {
            // TODO: iosConnectManager : 아직 값이 없음.
            iosConnectManager?.timeout = false
            iosConnectManager?.isFirstRequest = true
            secPlayed = false
            firstDecision(node: node)

        } else if node.nextId == nil {
            endingId = checkEndingCondition()
            await goToEndingNode(title: content.title, toId: endingId, context: context)

        } else if node.type == .exposition {
            iosConnectManager?.sendStageExpositionWithResume()
            await ttsManager.speakSequentially(node.text)
            self.goToNextNode(from: node)
        }
        self.isSequenceInProgress = false
    }

    private func checkEndingCondition() -> String {
        guard let story = currentNode?.story else { return "" }

        for condition in story.endingConditions {
            if condition.path == selectedPath {
                print("[INFO] 일치하는 엔딩 도달: \(condition.toId)")
                return condition.toId
            }
        }
        return ""
    }

    @MainActor
    private func goToEndingNode(
        title: String, toId: String, context: ModelContext
    ) async {
        isLoading = true
        do {
            if let story = try contentRepository.fetchStory(
                by: title, context: context),
                let endingNode = story.nodes.first(where: { $0.id == toId })
            {
                currentNode = endingNode
                // TODO: 아직 값이 없음.
                iosConnectManager?.sendStageEndingTTS()
                if !endingNode.text.isEmpty {
                    await ttsManager.speakSequentially(endingNode.text)
                }
                // TODO: 아직 값이 없음.
                iosConnectManager?.sendStageEndingTimer()
            } else {
                errorMessage = "해당 결말을 찾을 수 없습니다"
            }
        } catch {
            errorMessage = "스토리 로딩 실패: \(error.localizedDescription)"
        }
        isLoading = false
    }

    func toggleSpeaking() {
        if isTogglingTTS {
            print("[INFO] 잠시 토글 비활성화중")
            return
        }
        isTogglingTTS = true

        if isSpeaking {
            iosConnectManager?.sendStageExpositionWithPause()
        } else {
            iosConnectManager?.sendStageExpositionWithResume()
        }

        ttsManager.toggleSpeaking()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isTogglingTTS = false
        }
    }
    func handleWatchChoice(option: StoryChoiceOption) {
        guard let currentNode = currentNode else { return }
        iosConnectManager?.sendChoiceInterrupt()

        switch option {
        case .a:
            if let toId = currentNode.choiceA?.toId {
                selectChoice(toId: toId)
            }
        case .b:
            if let toId = currentNode.choiceB?.toId {
                selectChoice(toId: toId)
            }
        }
    }
    private func estimateDuration(for text: String) -> UInt64 {
        return UInt64(Double(text.count) * 0.1 * 1_000_000_000)
    }

    func firstDecision(node: StoryNode) {
        decisionTask?.cancel()
        decisionTask = Task {
            iosConnectManager?.sendStageDecisionWithFirstTTS(decisionIndex)
            if !node.text.isEmpty {
                await ttsManager.speakSequentially(node.text)
            }
            await ttsManager.speakSequentially("A")
            await ttsManager.speakSequentially(node.choiceA?.text ?? "")
            await ttsManager.speakSequentially("B")
            await ttsManager.speakSequentially(node.choiceB?.text ?? "")

            iosConnectManager?.sendStageDecisionWithFirstTimer(decisionIndex)
        }
    }

    func playSecDecisionTTS(node: StoryNode) {
        decisionTask?.cancel()
        secPlayed = true

        let texts = [
            "선택지가 다시 한번 재생됩니다",
            "A. \(node.choiceA?.text ?? "")",
            "B. \(node.choiceB?.text ?? "")",
        ]

        decisionTask = Task {
            secPlayed = true
            iosConnectManager?.sendStageDecisionWithSecTTS(decisionIndex)
            for text in texts { await ttsManager.speakSequentially(text) }
            let totalDelay =
                texts.map { estimateDuration(for: $0) }.reduce(0, +)
                + 200_000_000
            try? await Task.sleep(nanoseconds: totalDelay)
            iosConnectManager?.sendStageDecisionWithSecTimer(decisionIndex)
        }
    }

    func handleTimeout(_ newValue: Bool?) {
        let isTimeout = newValue == true
        let noSelection = iosConnectManager?.selectedOption == nil
        guard isTimeout, noSelection,
            let node = currentNode, node.type == .decision
        else { return }

        if iosConnectManager?.isFirstRequest == true {
            playSecDecisionTTS(node: node)
            iosConnectManager?.isFirstRequest = false
        } else {
            if let toId = node.choiceA?.toId {
                selectChoice(toId: toId)
            }
        }
        iosConnectManager?.timeout = false
    }

}
