//
//  WatchStartViewModel.swift
//  Pickacha Watch App
//
//  Created by jiwon on 6/1/25.
//

import AVFoundation
import Foundation

class WatchStartViewModel: ObservableObject {
    @Published var watchConnectivityManager: WatchConnectManager
    @Published var isStart = false
    private let synthesizer = AVSpeechSynthesizer()

    init(watchConnectivityManager: WatchConnectManager) {
        self.watchConnectivityManager = watchConnectivityManager
        self.isStart = watchConnectivityManager.startContent
    }

    func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "ko-KR")
        synthesizer.speak(utterance)
    }

    func speakIntro() {
        speak("이야기를 감상하려면 iPhone에서 앱을 실행해 주세요.")
    }
}
