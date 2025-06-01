//
//  TTSManager.swift
//  Kartrider
//
//  Created by 박난 on 6/2/25.
//

import AVFoundation
import Foundation

@MainActor
final class TTSManager: NSObject, ObservableObject {
    private let synthesizer = AVSpeechSynthesizer()
    var onFinish: (() -> Void)?

    @Published private(set) var isSpeaking: Bool = false
    @Published private(set) var isPaused: Bool = false

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    func speak(_ text: String) {
        stop()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let utterance = AVSpeechUtterance(string: text)
            utterance.voice = AVSpeechSynthesisVoice(language: "ko-KR")
            self.synthesizer.speak(utterance)
        }
    }


    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
        updateState(isSpeaking: false, isPaused: false)
    }

    func pause() {
        if synthesizer.pauseSpeaking(at: .word) {
            updateState(isSpeaking: false, isPaused: true)
        }
    }

    func resume() {
        if synthesizer.continueSpeaking() {
            updateState(isSpeaking: true, isPaused: false)
        }
    }

    private func updateState(isSpeaking: Bool, isPaused: Bool) {
        self.isSpeaking = isSpeaking
        self.isPaused = isPaused
    }
}

extension TTSManager: AVSpeechSynthesizerDelegate {
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        Task { @MainActor in self.updateState(isSpeaking: true, isPaused: false) }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        Task { @MainActor in self.updateState(isSpeaking: false, isPaused: true) }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
        Task { @MainActor in self.updateState(isSpeaking: true, isPaused: false) }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.updateState(isSpeaking: false, isPaused: false)
            self.onFinish?()
        }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.updateState(isSpeaking: false, isPaused: false)
//            self.onFinish?()
        }
    }
}
