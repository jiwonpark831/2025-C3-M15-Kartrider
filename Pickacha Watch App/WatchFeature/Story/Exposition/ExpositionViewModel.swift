//
//  ExpositionViewModel.swift
//  Pickacha Watch App
//
//  Created by jiwon on 6/3/25.
//

import Foundation

class ExpositionViewModel: ObservableObject {
    @Published var watchConnectivityManager: WatchConnectManager
    @Published var isPlayTTS = true

    init(watchConnectivityManager: WatchConnectManager) {
        self.watchConnectivityManager = watchConnectivityManager
        self.isPlayTTS = watchConnectivityManager.isPlayTTS
    }

    func toggleState() {
        isPlayTTS.toggle()
        if isPlayTTS == true {
            print("재생")
            watchConnectivityManager.sendStageExpositionWithResume()
        } else {
            watchConnectivityManager.sendStageExpositionWithPause()
            print("일시정지")
        }

    }
}
