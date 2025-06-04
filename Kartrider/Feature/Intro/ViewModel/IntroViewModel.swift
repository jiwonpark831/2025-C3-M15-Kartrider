//
//  IntroViewModel.swift
//  Kartrider
//
//  Created by J on 5/31/25.
//

import Foundation

class IntroViewModel: ObservableObject {
    @Published var content: ContentMeta

    init(content: ContentMeta) {
        self.content = content
        print(
            "[DEBUG] IntroViewModel 초기화 - 제목 : \(content.title), 타입 : \(content.type)"
        )
    }

    func sendStageIdleToWatch() {
        IosConnectManager.shared.sendStageIdle()
    }
}
