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

    func syncTTSState() {
        isPlayTTS = watchConnectivityManager.isPlayTTS
    }

    func toggleStateWatch() {
        isPlayTTS.toggle()
        watchConnectivityManager.isPlayTTS = isPlayTTS

        if isPlayTTS {
            print("[WATCH] 재생")
            watchConnectivityManager.sendStageExpositionWithResume()
        } else {
            print("[WATCH] 일시정지")
            watchConnectivityManager.sendStageExpositionWithPause()
        }
    }

    func updateStateByIos(_ newValue: Bool) {
        guard newValue != isPlayTTS else { return }
        print("[WATCH] from iOS: \(newValue)")
        isPlayTTS = newValue
    }
    
    //    func toggleState() {
    //        isPlayTTS.toggle()
    //        watchConnectivityManager.isPlayTTS = isPlayTTS
    //
    //        if isPlayTTS == true {
    //            print("재생")
    //            watchConnectivityManager.sendStageExpositionWithResume()
    //        } else {
    //            watchConnectivityManager.sendStageExpositionWithPause()
    //            print("일시정지")
    //        }
    //
    //    }

}
