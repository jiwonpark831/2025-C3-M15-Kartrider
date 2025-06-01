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
    var storyNode: StoryNode?
    @Published var state: StoryNodeLoadState = .loading
    
    init(repository: ContentRepositoryProtocol = ContentRepository(), title: String, id: String) {
        self.contentRepository = repository
        self.title = title
        self.id = id
    }
    
    @MainActor
    func loadStoryNode(context: ModelContext) {
        do {
            if let story = try contentRepository.fetchStory(by: title, context: context), let storyNode = story.nodes.first(where: { $0.id == id }){
                state = .success(storyNode)
            } else {
                state = .failure("해당 스토리를 찾을 수 없습니다")
            }
        } catch {
            print("[ERROR] 스토리 로딩 실패 (id: \(id)")
        }
    }
}
