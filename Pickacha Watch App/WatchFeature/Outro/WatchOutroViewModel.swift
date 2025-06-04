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
    @Published var progress: CGFloat = 0.0
    @Published var isEndingPlay = false

    private var timer: Timer?
    

    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {
            _ in
            if self.time > 0 {
                self.time -= 1
                WKInterfaceDevice.current().play(.start)
            } else {
                self.timer?.invalidate()
                print("time out")
            }
        }
    }
}
