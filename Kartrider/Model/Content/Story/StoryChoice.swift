//
//  StoryChoice.swift
//  Kartrider
//
//  Created by J on 5/29/25.
//

import Foundation
import SwiftData

@Model
class StoryChoice {
    var text: String
    var toId: String
    
    init(text: String, toId: String) {
        self.text = text
        self.toId = toId
    }
}

