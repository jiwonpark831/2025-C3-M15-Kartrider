//
//  TenSecTimer.swift
//  Pickacha Watch App
//
//  Created by jiwon on 6/1/25.
//

import SwiftUI

struct TenSecTimer: View {

//    let action: () -> Void

    @State private var timer: Timer?
    @State private var time = 10

    var body: some View {
        ZStack {
            ProgressView().progressViewStyle(.circular)
            Text("\(time)").onAppear { startTimer() }
        }
    }

    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {
            _ in
            if time > 0 {
                time -= 1
                //                WKInterfaceDevice.current().play(.start)
            } else {
                timer?.invalidate()
                print("time out")
            }
        }
    }
}

//#Preview {
//    TenSecTimer()
//}
