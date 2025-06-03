//
//  Route.swift
//  Kartrider
//
//  Created by jiwon on 5/27/25.
//

import Foundation

enum Route: Hashable {
    case home
    case intro(ContentMeta)
    case story(String, String)
    case tournament(String, UUID)
    case outro
    case storage
    case history
    case historyTimeline
}
