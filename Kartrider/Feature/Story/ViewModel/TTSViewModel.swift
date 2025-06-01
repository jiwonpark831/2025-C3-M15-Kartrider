//
//  TTSViewModel.swift
//  Kartrider
//
//  Created by 박난 on 6/2/25.
//

import Foundation

@MainActor
final class TTSViewModel: ObservableObject {
    @Published private(set) var isSpeaking = false
    @Published private(set) var isPaused = false

    var onFinish: (() -> Void)?

    private let ttsManager = TTSManager()

    init() {
        ttsManager.didFinishSpeaking = { [unowned self] in
            self.isSpeaking = false
            self.isPaused = false
            self.onFinish?()
        }
    }

    func speak(_ text: String) {
        ttsManager.speak(text)
        syncState()
    }

    func stop() {
        ttsManager.stop()
        onFinish = nil
        syncState()
    }

    func pause() {
        ttsManager.pause()
        syncState()
    }

    func resume() {
        ttsManager.resume()
        syncState()
    }

    func reset() {
        stop()
        onFinish = nil
    }

    private func syncState() {
        isSpeaking = ttsManager.isSpeaking
        isPaused = ttsManager.isPaused
    }
}

