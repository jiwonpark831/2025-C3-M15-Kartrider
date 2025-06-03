//
//  WatchStoryViewModel.swift
//  Pickacha Watch App
//
//  Created by jiwon on 6/1/25.
//

import Foundation

enum StoryNodeType {
    case exposition
    case decision
    case ending
}

class WatchStoryViewModel: ObservableObject {
    @Published var storyNodeType: StoryNodeType = .decision

}
