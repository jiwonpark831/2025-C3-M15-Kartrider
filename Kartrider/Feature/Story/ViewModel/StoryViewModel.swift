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
    @Published var state: StoryNodeLoadState = .loading

    init(repository: ContentRepositoryProtocol = ContentRepository(), title: String, id: String) {
        self.contentRepository = repository
        self.title = title
        self.id = id
    }

    @MainActor
    func loadStoryNode(context: ModelContext) async {
        do {
            if let story = try contentRepository.fetchStory(by: title, context: context),
               let storyNode = story.nodes.first(where: { $0.id == id }) {
                state = .success(storyNode)
            } else {
                state = .failure("해당 스토리를 찾을 수 없습니다")
            }
        } catch {
            state = .failure("스토리 로딩 실패: \(error.localizedDescription)")
        }
    }

    func goToNextNode(from currentNode: StoryNode) {
        guard let nextId = currentNode.nextId,
              let nextNode = currentNode.story.nodes.first(where: { $0.id == nextId }) else {
            state = .failure("다음 스토리 노드를 찾을 수 없습니다")
            return
        }
        state = .success(nextNode)
    }
}
