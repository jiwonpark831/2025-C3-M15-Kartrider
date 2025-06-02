//
//  HomeViewModel.swift
//  Kartrider
//
//  Created by J on 5/31/25.
//

import Foundation
import SwiftData

class HomeViewModel: ObservableObject {
    
    @Published var contents: [ContentMeta] = []
    
    private let contentRepository: ContentRepositoryProtocol
    
    init(repository: ContentRepositoryProtocol = ContentRepository()) {
        self.contentRepository = repository
    }
    
    @MainActor
    func loadContents(context: ModelContext) {
        do {
            contents = try contentRepository.fetchAllContents(context: context).shuffled()
        } catch {
            print("[ERROR] 컨텐츠 로딩 실패 : \(error)")
        }
    }
}
