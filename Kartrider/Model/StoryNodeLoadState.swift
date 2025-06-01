//
//  LoadState.swift
//  Kartrider
//
//  Created by 박난 on 6/2/25.
//

enum StoryNodeLoadState {
    case loading
    case success(StoryNode)
    case failure(String)
}
