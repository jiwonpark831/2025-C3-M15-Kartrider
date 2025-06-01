//
//  WatchStartView.swift
//  Pickacha Watch App
//
//  Created by jiwon on 5/31/25.
//

import AVFoundation
import SwiftUI

struct WatchStartView: View {

    @EnvironmentObject private var coordinator: WatchNavigationCoordinator

    @State private var isStart = false
    // isStart를 가져오는 코드가 필요해!
    private let synthesizer = AVSpeechSynthesizer()

    var body: some View {
        VStack {
            if !isStart {
                Text("이야기를 감상하려면 iPhone에서 앱을 실행해 주세요.")
                    .onAppear { speak("이야기를 감상하려면 iPhone에서 앱을 실행해 주세요.") }
            } else {
                WatchStoryView()
            }

        }
    }

    func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "ko-KR")
        synthesizer.speak(utterance)
    }

}

#Preview {
    WatchStartView()
}
