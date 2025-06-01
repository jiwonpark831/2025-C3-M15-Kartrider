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

    @Published var isLoading: Bool = true
    @Published var errorMessage: String?
    @Published var currentNode: StoryNode?

    init(repository: ContentRepositoryProtocol = ContentRepository(), title: String, id: String) {
        self.contentRepository = repository
        self.title = title
        self.id = id
    }

    @MainActor
    func loadInitialNode(context: ModelContext) async {
        isLoading = true
        errorMessage = nil
        do {
            if let story = try contentRepository.fetchStory(by: title, context: context),
               let node = story.nodes.first(where: { $0.id == id }) {
                currentNode = node
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
              let nextNode = currentNode.story.nodes.first(where: { $0.id == nextId }) else {
            errorMessage = "다음 스토리 노드를 찾을 수 없습니다"
            return
        }
        self.currentNode = nextNode
    }

    func selectChoice(toId: String) {
        guard let currentNode,
              let nextNode = currentNode.story.nodes.first(where: { $0.id == toId }) else {
            errorMessage = "선택한 노드를 찾을 수 없습니다"
            return
        }
        self.currentNode = nextNode
    }
}
