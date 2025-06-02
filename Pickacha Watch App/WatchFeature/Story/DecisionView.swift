//
//  DecisionView.swift
//  Pickacha Watch App
//
//  Created by jiwon on 6/2/25.
//

import CoreMotion
import SwiftUI
import WatchKit

struct DecisionView: View {

    @State private var timer: Timer?
    @State private var time = 10

    @State private var middle: Double = 0.0
    @State private var choice: String?
    @State private var motionManager = CMMotionManager()

    var body: some View {
        VStack {
            Text("손목을 돌려서 선택")
            ZStack {
                ProgressView().progressViewStyle(.circular)
                Text("\(time)").onAppear { startTimer() }
            }
            HStack {
                Text("1번").foregroundStyle(
                    choice == "1번" ? Color.orange : Color.white)
                Spacer()
                Text("2번").foregroundStyle(
                    choice == "2번" ? Color.orange : Color.white)
            }
        }.onAppear {
            startTimer()
            makeChoice()
        }
    }
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {
            _ in
            if time > 0 {
                time -= 1
                WKInterfaceDevice.current().play(.start)
            } else {
                timer?.invalidate()
                print("time out")
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
                choice = "2번"
                print("2번")
                timer?.invalidate()
                motionManager.stopDeviceMotionUpdates()
            } else if value < -0.5 {
                choice = "1번"
                print("1번")
                timer?.invalidate()
                motionManager.stopDeviceMotionUpdates()
            }
        }
    }
}

#Preview {
    DecisionView()
}
