//
//  PlayHistoryRepositoryProtocol.swift
//  Kartrider
//
//  Created by J on 5/30/25.
//

import Foundation

protocol PlayHistoryRepositoryProtocol {
    func fetchAllHistories() throws -> [PlayHistory]
    func fetchHistory(for contentId: UUID) throws -> PlayHistory?
    func saveStoryHistory(for contentId: UUID, steps: [StoryStep]) throws
}
