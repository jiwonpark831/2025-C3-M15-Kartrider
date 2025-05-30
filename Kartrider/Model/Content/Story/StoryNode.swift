//
//  StoryNode.swift
//  Kartrider
//
//  Created by J on 5/29/25.
//

import Foundation
import SwiftData

@Model
class StoryNode {
    @Attribute(.unique) var id: String
    var text: String
    var type: StoryNodeType
    var nextId: String?
    var endingIndex: Int?
    
    @Relationship(inverse: \Story.nodes) var story: Story
    @Relationship(deleteRule: .cascade) var choiceA: StoryChoice?
    @Relationship(deleteRule: .cascade) var choiceB: StoryChoice?
    
    init(
        id: String,
        text: String,
        type: StoryNodeType,
        nextId: String? = nil,
        endingIndex: Int? = nil,
        story: Story
    ) {
        self.id = id
        self.text = text
        self.type = type
        self.nextId = nextId
        self.endingIndex = endingIndex
        self.story = story
    }
}


