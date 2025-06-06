//
//  StoryViewModel.swift
//  Kartrider
//
//  Created by J on 5/31/25.
//
import Foundation
import SwiftData

class StoryViewModel: ObservableObject {
    let title: String
    let id: String
    private let contentRepository: ContentRepositoryProtocol
    private var lastToggleTime: Date = .distantPast

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

    var ttsManager = TTSManager()

    init(
        repository: ContentRepositoryProtocol = ContentRepository(),
        title: String, id: String
    ) {
        self.contentRepository = repository
        self.title = title
        self.id = id

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
                by: title, context: context),
                let node = story.nodes.first(where: { $0.id == id })
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
            let nextNode = currentNode.story.nodes.first(where: {
                $0.id == nextId
            })
        else {
            errorMessage = "다음 스토리 노드를 찾을 수 없습니다"
            return
        }
        Task { @MainActor in
            self.currentNode = nextNode
        }
    }

    func selectChoice(toId: String) {
        guard let currentNode,
            let nextNode = currentNode.story.nodes.first(where: {
                $0.id == toId
            })
        else {
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
            iosConnectManager?.sendStageDecisionWithFirstTTS(decisionIndex)

            await ttsManager.speakSequentially("A")
            await ttsManager.speakSequentially(node.choiceA?.text ?? "")
            await ttsManager.speakSequentially("B")
            await ttsManager.speakSequentially(node.choiceB?.text ?? "")
            try? await Task.sleep(for: .milliseconds(300))
            iosConnectManager?.sendStageDecisionWithFirstTimer(decisionIndex)
        } else if node.nextId == nil {
            endingId = checkEndingCondition()
            goToEndingNode(title: title, toId: endingId, context: context)

        } else if node.type == .exposition {
            iosConnectManager?.sendStageExpositionWithResume()
            //            if !isSpeaking {
            await ttsManager.speakSequentially(node.text)
            //            }
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
    ) {
        isLoading = true
        do {
            if let story = try contentRepository.fetchStory(
                by: title, context: context),
                let endingNode = story.nodes.first(where: { $0.id == toId })
            {
                currentNode = endingNode
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

}
