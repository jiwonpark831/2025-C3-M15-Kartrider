//
//  Item.swift
//  Kartrider
//
//  Created by jiwon on 5/27/25.
//

import Foundation
import SwiftData

// TODO: 지우세요~
@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
