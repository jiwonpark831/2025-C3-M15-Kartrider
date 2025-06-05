//
//  WatchStoryViewModel.swift
//  Pickacha Watch App
//
//  Created by jiwon on 6/1/25.
//

import Foundation

class WatchStoryViewModel: ObservableObject {
    @Published var storyNodeTypeRaw: String = "idle"

    @Published var decisionViewModel = DecisionViewModel()
}
