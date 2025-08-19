//
//  iOSTimer.swift
//  Kartrider
//
//  Created by jiwon on 8/19/25.
//

import Combine
import Foundation
import SwiftUI

struct iOSTimer: View {
    @StateObject private var iOSTimerViewModel = IOSTimerViewModel()

    var body: some View {
        ZStack {
            Circle()
                .trim(from: 1 - iOSTimerViewModel.progress, to: 1)
                .stroke(
                    Color.orange,
                    style: StrokeStyle(
                        lineWidth: 2,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .frame(width: 73, height: 73)
                .animation(
                    .linear(duration: 1),
                    value: iOSTimerViewModel.progress
                )
            Text("\(iOSTimerViewModel.time)")
                .font(.system(.title))
        }
    }

}

#Preview {
    iOSTimer()
}

class IOSTimerViewModel: ObservableObject {

    let connectManager = ConnectManager.shared

    private var cancellable = Set<AnyCancellable>()

    @Published var isTimerRunning = false
    @Published var time = 10
    @Published var progress: CGFloat = 1.0

    private var timer: Timer?

    init() {
        connectManager.$timerEnd
            .receive(on: DispatchQueue.main)
            .sink { newValue in
                if newValue != nil {
                    self.resetState()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self.isTimerRunning = true
                        self.startTimer(endDate: newValue!)
                    }
                } else {
                    self.stopTimer()
                }
                print("[DECISION] isTimerRunning: \(self.isTimerRunning)")
            }
            .store(in: &cancellable)
    }

    func resetState() {
        time = 10
        progress = 1.0
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
        isTimerRunning = false
        resetState()
    }

    func startTimer(endDate: Date) {
        timer?.invalidate()
        timer = nil

        DispatchQueue.main.async {
            self.isTimerRunning = true
        }

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in

            let remainTime = endDate.timeIntervalSinceNow

            if remainTime > 0 {
                // 올림, Int로
                let timeCountdown = Int(ceil(remainTime))
                print("[TIMER] \(timeCountdown)")
                self.time = timeCountdown
                self.progress = CGFloat(remainTime) / 10.0
            } else {
                self.stopTimer()
                self.connectManager.timerEnd = nil
            }
        }
    }
}
