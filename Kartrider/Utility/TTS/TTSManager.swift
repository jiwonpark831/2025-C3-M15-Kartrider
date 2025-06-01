//
//  TTSManager.swift
//  Kartrider
//
//  Created by 박난 on 6/2/25.
//
import AVFoundation
import Foundation
import AVFoundation

final class TTSManager: NSObject, ObservableObject {
    private let synthesizer = AVSpeechSynthesizer()
    private var utteranceQueue: [AVSpeechUtterance] = []

    var onFinish: (() -> Void)?

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    func speak(_ text: String) {
        stop()
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "ko-KR")
        synthesizer.speak(utterance)
    }

    func stop() {
        synthesizer.stopSpeaking(at: .immediate)
    }

    func pause() {
        _ = synthesizer.pauseSpeaking(at: .word)
    }

    func resume() {
        _ = synthesizer.continueSpeaking()
    }

    var isSpeaking: Bool {
        synthesizer.isSpeaking
    }

    var isPaused: Bool {
        synthesizer.isPaused
    }
}

extension TTSManager: AVSpeechSynthesizerDelegate {
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.onFinish?()
        }
    }

    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.onFinish?()
        }
    }
}


