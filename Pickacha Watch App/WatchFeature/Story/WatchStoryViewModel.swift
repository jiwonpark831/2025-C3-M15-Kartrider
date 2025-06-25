//
//  WatchStoryViewModel.swift
//  Pickacha Watch App
//
//  Created by jiwon on 6/1/25.
//

import Foundation

class WatchStoryViewModel: ObservableObject {
    @Published var watchConnectivityManager: WatchConnectManager
    // MARK: 시간되면 ENUM 타입으로 변경
    @Published var storyType: String = "idle"

    init(watchConnectivityManager: WatchConnectManager) {
        self.watchConnectivityManager = watchConnectivityManager
    }

    func updateStage() {
        self.storyType = watchConnectivityManager.stage
    }
}
