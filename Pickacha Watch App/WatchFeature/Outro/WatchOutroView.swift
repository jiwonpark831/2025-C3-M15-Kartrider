//
//  WatchOutroView.swift
//  Pickacha Watch App
//
//  Created by jiwon on 5/31/25.
//

import AVFoundation
import SwiftUI

struct WatchOutroView: View {

    @EnvironmentObject private var coordinator: WatchNavigationCoordinator
    @State private var timer: Timer?
    @State private var time = 10

    var body: some View {
        VStack {
            ZStack {
                ProgressView().progressViewStyle(.circular)
                Text("\(time)").onAppear { startTimer() }
            }
            Text("10초 후 다음 이야기가 재생됩니다.")
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
}

#Preview {
    WatchOutroView()
}
