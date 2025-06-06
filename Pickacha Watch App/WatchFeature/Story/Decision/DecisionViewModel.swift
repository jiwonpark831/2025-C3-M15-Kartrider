//
//  DecisionViewModel.swift
//  Pickacha Watch App
//
//  Created by jiwon on 6/3/25.
//

import CoreMotion
import Foundation
import WatchKit

class DecisionViewModel: ObservableObject {

    @Published var watchConnectivityManager: WatchConnectManager

    @Published var isStartTimer = false
    @Published var decisionIndex = 0
    @Published var isInterrupt = false
    @Published var isFirstRequest = true

    @Published var choice: String?
    @Published var time = 10
    @Published var progress: CGFloat = 0.0
    @Published var isTimeOut = false

    private var middle: Double = 0.0
    private var timer: Timer?
    private var motionManager = CMMotionManager()

    init(watchConnectivityManager: WatchConnectManager) {
        self.watchConnectivityManager = watchConnectivityManager
        self.isStartTimer = watchConnectivityManager.timerStarted
        self.decisionIndex = watchConnectivityManager.decisionIndex
        self.isInterrupt = watchConnectivityManager.isInterrupt
        self.isFirstRequest = watchConnectivityManager.isFirstRequest
    }

    func startTimer() {
        self.timer?.invalidate()
        self.timer = nil

        self.isStartTimer = true
        self.progress = 1.0
        self.time = 10
        self.isTimeOut = false
        timer?.invalidate()

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {
            _ in
            if self.time > 0 {
                self.time -= 1
                WKInterfaceDevice.current().play(.start)
            } else {
                if !self.isTimeOut {
                    self.timer?.invalidate()
                    self.timer = nil
                    self.isStartTimer = false
                    self.isTimeOut = true
                    self.time = 0
                    self.progress = 0.0
                    print("time out")
                    self.motionManager.stopDeviceMotionUpdates()
                }
            }
        }
    }

    func makeChoice() {
        guard motionManager.isDeviceMotionAvailable else {
            print("unavailable")
            return
        }

        middle = 0.0
        motionManager.deviceMotionUpdateInterval = 0.1

        motionManager.startDeviceMotionUpdates(to: .main) {
            (deviceMotion: CMDeviceMotion?, error: Error?) in
            guard let data = deviceMotion, error == nil else {
                print(
                    "Failed to get device motion data: \(error?.localizedDescription ?? "Unknown error")"
                )
                return
            }

            let roll = data.attitude.roll
            let value = roll - self.middle
            if value > 0.5 {
                self.choice = "2번"
                print("2번")
                self.timer?.invalidate()
                self.motionManager.stopDeviceMotionUpdates()
                if self.isFirstRequest {
                    self.watchConnectivityManager.sendFirstChoiceToIos(
                        self.decisionIndex, "B")

                } else {
                    self.watchConnectivityManager.sendSecChoiceToIos(
                        self.decisionIndex, "B")
                }
            } else if value < -0.5 {
                self.choice = "1번"
                print("1번")
                self.timer?.invalidate()
                self.motionManager.stopDeviceMotionUpdates()
                if self.isFirstRequest {
                    self.watchConnectivityManager.sendFirstChoiceToIos(
                        self.decisionIndex, "A")
                } else {
                    self.watchConnectivityManager.sendSecChoiceToIos(
                        self.decisionIndex, "A")
                }
            }
        }
    }
}
