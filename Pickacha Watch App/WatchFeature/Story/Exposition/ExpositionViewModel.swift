//
//  ExpositionViewModel.swift
//  Pickacha Watch App
//
//  Created by jiwon on 6/3/25.
//

import Foundation

class ExpositionViewModel: ObservableObject {
    @Published var isPlayTTS = true

    func toggleState() {
        isPlayTTS.toggle()
        if isPlayTTS == true {
            print("재생")
            WatchConnectManager.shared.sendStageExpositionWithResume()
        } else {
            WatchConnectManager.shared.sendStageExpositionWithPause()
            print("일시정지")
        }

    }
}
