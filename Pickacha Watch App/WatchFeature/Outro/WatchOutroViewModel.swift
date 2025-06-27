//
//  WatchOutroViewModel.swift
//  Pickacha Watch App
//
//  Created by jiwon on 6/1/25.
//

import Foundation
import WatchKit

class WatchOutroViewModel: ObservableObject {
    @Published var time = 10
    @Published var progress: CGFloat = 1.0
    @Published var isTimerStart = false

    private var connectManager: WatchConnectManager

    private var timer: Timer?

    init(connectManager: WatchConnectManager) {
        self.connectManager = connectManager
    }

    func startTimer() {
        guard !isTimerStart else { return }
        isTimerStart = true
        connectManager.timerStarted = true

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if self.time > 0 {
                self.time -= 1
                self.progress = CGFloat(self.time) / 10.0
                WKInterfaceDevice.current().play(.start)
            } else {
                self.timer?.invalidate()
                print("[ENDING] Time Out")
            }
        }
    }
}
