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
    
    private var currentContinuation: CheckedContinuation<Void, Never>?


    var onFinish: (() -> Void)?

    private let ttsManager = TTSManager()

    init() {
        ttsManager.didFinishSpeaking = { [unowned self] in
            self.isSpeaking = false
            self.isPaused = false

            let callback = self.onFinish
            self.onFinish = nil
            callback?()
        }
    }

    func speak(_ text: String) {
        ttsManager.speak(text)
        syncState()
    }
    
    func speakSequentially(_ text: String) async {
        await withCheckedContinuation { continuation in
            self.currentContinuation = continuation

            self.onFinish = {
                continuation.resume()
                self.currentContinuation = nil
            }

            self.speak(text)
        }
    }


    func stop() {
        onFinish = nil

        if let continuation = currentContinuation {
            continuation.resume()
            currentContinuation = nil
        }

        ttsManager.stop()
        isSpeaking = false
        isPaused = false
    }



    func pause() {
        ttsManager.pause()
        isSpeaking = false
        isPaused = true
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

