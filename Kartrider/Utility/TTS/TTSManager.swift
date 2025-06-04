//
//  TTSManager.swift
//  Kartrider
//
//  Created by 박난 on 6/2/25.
//
import Foundation
import AVFoundation

final class TTSManager: NSObject, @unchecked Sendable, ObservableObject {
    private let synthesizer = AVSpeechSynthesizer()

    private var currentContinuation: CheckedContinuation<Void, Never>?
    @Published var isSpeaking = false
    private(set) var isPaused = false

    var didFinishSpeaking: (() -> Void)?
    var didSpeakingStateChanged: ((Bool) -> Void)?

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    func speak(_ text: String) {
        synthesizer.stopSpeaking(at: .immediate)
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "ko-KR")
        synthesizer.speak(utterance)
    }

    func speakSequentially(_ text: String) async {
        if currentContinuation != nil {
            stop()
        }

        await withCheckedContinuation { continuation in
            currentContinuation = continuation
            speak(text)

            DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
                if self.currentContinuation != nil {
                    print("[TTS] fallback timeout – forcing stop")
                    self.stop()
                }
            }
        }
    }


    func stop() {
        synthesizer.stopSpeaking(at: .immediate)

        currentContinuation = nil
        isSpeaking = false
        isPaused = false
    }

    func pause() {
        if synthesizer.pauseSpeaking(at: .word) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                if !self.synthesizer.isSpeaking {
                    self.isSpeaking = false
                    self.isPaused = true
                }
            }
        }
    }

    func resume() {
        if synthesizer.continueSpeaking() {
            isSpeaking = true
            isPaused = false
        }
    }
}

extension TTSManager: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        isSpeaking = true
        isPaused = false
        didSpeakingStateChanged?(true)
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        isSpeaking = false
        isPaused = true
        didSpeakingStateChanged?(false)
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
        isSpeaking = true
        isPaused = false
        didSpeakingStateChanged?(true)
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        isSpeaking = false
        isPaused = false

        if let continuation = currentContinuation {
            continuation.resume()
            currentContinuation = nil
        }

        didFinishSpeaking?()
        didFinishSpeaking = nil
        didSpeakingStateChanged?(false)
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        isSpeaking = false
        isPaused = false
        didSpeakingStateChanged?(false)
    }
}

