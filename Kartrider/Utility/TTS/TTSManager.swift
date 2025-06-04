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

    @MainActor @Published private(set) var state: TTSState = .idle
    var didSpeakingStateChanged: ((Bool) -> Void)?

    override init() {
        super.init()
        synthesizer.delegate = self
    }

    func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "ko-KR")
        synthesizer.speak(utterance)
    }

    func speakSequentially(_ text: String) async {
        print("[INFO] speakSequentially 호출")
        
        while await self.state == .paused {
            print("[DEBUG] [speakSequentially] 일시정지 상태, 재생될 때까지 대기...")
            try? await Task.sleep(for: .milliseconds(100))
        }

        let currentState = await self.state
        guard currentState == .idle || currentState == .finished else {
            print("[WARN] 현재 발화 중 → 새 발화 무시")
            return
        }

        await withCheckedContinuation { [weak self] continuation in
            guard let self else {
                continuation.resume()
                return
            }

            self.currentContinuation = continuation
            self.speak(text)
        }
    }

    func pause() {
        print("[DEBUG] pause 호출")
        guard synthesizer.isSpeaking else {
            print("[WARN] pause 호출 시 재생 중이 아님")
            return
        }

        if synthesizer.pauseSpeaking(at: .word) {
            Task { @MainActor in
                self.state = .paused
                self.didSpeakingStateChanged?(false)
            }
        }
    }

    func resume() {
        print("[DEBUG] resume 호출")
        guard synthesizer.isPaused else {
            print("[WARN] resume 호출 시 일시정지 상태가 아님")
            return
        }

        if synthesizer.continueSpeaking() {
            Task { @MainActor in
                self.state = .playing
                self.didSpeakingStateChanged?(true)
            }
        }
    }

    func stop() {
        print("[DEBUG] stop 호출")
        synthesizer.stopSpeaking(at: .immediate)
        currentContinuation = nil

        Task { @MainActor in
            self.state = .idle
            self.didSpeakingStateChanged?(false)
        }
    }

    func toggleSpeaking() {
        print("[INFO] toggleSpeaking 호출")
        Task { @MainActor in
            switch state {
            case .playing:
                pause()
            case .paused:
                resume()
            default:
                print("[WARN] toggleSpeaking: 일시정지/재생 가능한 상태가 아님")
            }
        }
    }
}

extension TTSManager: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.state = .playing
            self.didSpeakingStateChanged?(true)
        }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.state = .paused
            self.didSpeakingStateChanged?(false)
        }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.state = .playing
            self.didSpeakingStateChanged?(true)
        }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.state = .finished
            self.didSpeakingStateChanged?(false)
        }

        if let continuation = currentContinuation {
            continuation.resume()
            currentContinuation = nil
        }
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        Task { @MainActor in
            self.state = .idle
            self.didSpeakingStateChanged?(false)
        }
    }
}
