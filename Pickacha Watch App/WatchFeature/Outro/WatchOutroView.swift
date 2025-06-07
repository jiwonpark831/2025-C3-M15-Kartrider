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
    @EnvironmentObject private var connectManager: WatchConnectManager
    @StateObject private var watchOutroViewModel: WatchOutroViewModel

    init(connectManager: WatchConnectManager) {
        _watchOutroViewModel = StateObject(
            wrappedValue: WatchOutroViewModel(
                connectManager: connectManager))

    }

    var body: some View {
        Group {
            if watchOutroViewModel.isTimerStart {
                VStack {
                    ZStack {
                        Circle()
                            .trim(from: 1 - watchOutroViewModel.progress, to: 1)
                            .stroke(
                                Color.orange,
                                style: StrokeStyle(
                                    lineWidth: 2, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                            .frame(width: 73, height: 73)
                            .animation(
                                .linear(duration: 1),
                                value: watchOutroViewModel.progress
                            )
                        Text("\(watchOutroViewModel.time)").font(
                            .system(size: 30, weight: .light))
                    }
                    Spacer().frame(height: 14)
                    Group {
                        Text("10초 후")
                        Text("다음 이야기가 재생됩니다.")
                    }
                    .font(.system(size: 10, weight: .regular))
                }
            } else {
                ZStack {

                    Circle()
                        .stroke(
                            Color.orange,
                            style: StrokeStyle(lineWidth: 2, lineCap: .round)
                        )
                        .frame(width: 121, height: 121)
                    VStack(spacing: 16) {
                        Text("결말이\n재생중입니다")
                            .font(.system(size: 13, weight: .medium))
                            .multilineTextAlignment(.center)
                    }
                }
            }
        }.onChange(of: connectManager.timerStarted) { newValue in
            print("[View] timer state change: \(newValue)")
            if newValue {
                watchOutroViewModel.startTimer()
            }
        }
        .onAppear {
            if connectManager.timerStarted {
                watchOutroViewModel.startTimer()
            }
        }
    }
}
