//
//  TTSViewModel.swift
//  Kartrider
//
//  Created by 박난 on 6/2/25.
//

import Foundation
import Combine

@MainActor
final class TTSViewModel: ObservableObject {
    @Published private(set) var isSpeaking: Bool = false
    @Published private(set) var isPaused: Bool = false

    private let ttsManager = TTSManager()
    private var cancellables = Set<AnyCancellable>()

    var onFinish: (() -> Void)?

    init() {
        ttsManager.$isSpeaking.assign(to: &$isSpeaking)
        ttsManager.$isPaused.assign(to: &$isPaused)

        ttsManager.onFinish = { [weak self] in
            self?.onFinish?()
        }
    }

    func speak(_ text: String) {
        ttsManager.speak(text)
    }

    func stop() {
        ttsManager.stop()
    }

    func pause() {
        ttsManager.pause()
    }

    func resume() {
        ttsManager.resume()
    }
}
