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
    @Published var isInterrupt = false
    @Published var isFirstRequest = true
    @Published var decisionIndex = 0

    @Published var choice: String?
    @Published var time = 10
    @Published var progress: CGFloat = 1.0
    @Published var isTimeOut = false

    private var middle: Double = 0.0
    private var timer: Timer?
    private var motionManager = CMMotionManager()
    private var isSetMiddle = false

    init(watchConnectivityManager: WatchConnectManager) {
        self.watchConnectivityManager = watchConnectivityManager
        self.isStartTimer = watchConnectivityManager.timerStarted
        self.decisionIndex = watchConnectivityManager.decisionIndex
        self.isInterrupt = watchConnectivityManager.isInterrupt
        self.isFirstRequest = watchConnectivityManager.isFirstRequest
    }

    func resetState() {
        timer?.invalidate()
        timer = nil
        motionManager.stopDeviceMotionUpdates()
        isStartTimer = false
        isTimeOut = false
        choice = nil
        time = 10
        progress = 1.0
        middle = 0.0
        isSetMiddle = false
    }

    // TODO: 중복되는 코드들 분리
    func startTimer() {
        self.timer?.invalidate()
        self.timer = nil
        self.progress = 1.0
        self.time = 10
        self.isTimeOut = false
        self.isStartTimer = true
        self.choice = nil
        self.middle = 0.0

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            print("[TIMER] \(self.time)")
            if self.time > 0 {
                self.time -= 1
                self.progress = CGFloat(self.time) / 10.0
                WKInterfaceDevice.current().play(.start)
            } else {
                if !self.isTimeOut {
                    self.timer?.invalidate()
                    self.timer = nil
                    self.isStartTimer = false
                    self.isTimeOut = true
                    self.time = 0
                    self.progress = 0.0
                    print("[DECISION] Time Out")
                    self.motionManager.stopDeviceMotionUpdates()

                    self.watchConnectivityManager.sendTimeoutToIos(self.decisionIndex,isFirstRequest: self.isFirstRequest)
                }
            }
        }
    }

    // TODO: 기능 단위로 조금 쪼개자.
    func makeChoice() {

        guard motionManager.isDeviceMotionAvailable else {
            print("unavailable")
            return
        }

        motionManager.deviceMotionUpdateInterval = 0.1
        isSetMiddle = false
        middle = 0.0

        motionManager.startDeviceMotionUpdates(to: .main) { data, error in
            guard let data = data, error == nil else {
                print("Motion data error: \(error?.localizedDescription ?? "Unknown")")
                return
            }
            
            guard self.choice == nil else { return }
            
            guard self.isStartTimer else { return }
            
            let roll = data.attitude.roll

            if !self.isSetMiddle {
                self.middle = roll
                self.isSetMiddle = true
                print("[MOTION] middle set: \(roll)")

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.startTimer()
                }
                return
            }
            

            let value = roll - self.middle
            
            if value > 0.6 {
                self.choice = "B"
                self.timer?.invalidate()
                self.motionManager.stopDeviceMotionUpdates()
                print("[CHOICE] B")
                if self.isFirstRequest {
                    self.watchConnectivityManager.sendFirstChoiceToIos(self.decisionIndex, "B")
                } else {
                    self.watchConnectivityManager.sendSecChoiceToIos(self.decisionIndex, "B")
                }
            } else if value < -0.6 {
                self.choice = "A"
                self.timer?.invalidate()
                self.motionManager.stopDeviceMotionUpdates()
                print("[CHOICE] A")
                if self.isFirstRequest {
                    self.watchConnectivityManager.sendFirstChoiceToIos(self.decisionIndex, "A")
                } else {
                    self.watchConnectivityManager.sendSecChoiceToIos(self.decisionIndex, "A")
                }
            }
        }
    }

    func interruptByPhone() {
        print("[WATCH] choice done in phone")
        timer?.invalidate()
        timer = nil
        motionManager.stopDeviceMotionUpdates()
        isStartTimer = false
    }
}
