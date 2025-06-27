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
                        Text("\(watchOutroViewModel.time)")
                            .font(.system(.title))
                    }
                    Spacer().frame(height: 20)
                    Group {
                        Text("10초 후")
                        Text("다음 이야기가 재생됩니다.")
                    }
                    .font(.system(.footnote))
                }
            } else {
                ZStack {
                    Circle()
                        .stroke(
                            Color.orange,
                            style: StrokeStyle(lineWidth: 3, lineCap: .round)
                        )
                        .frame(width: 140, height: 140)
                    VStack(spacing: 16) {
                        Text("결말이\n재생중입니다")
                            .font(.system(.headline))
                            .multilineTextAlignment(.center)
                    }
                }
            }
        }.onChange(of: connectManager.isTimerRunning) { newValue in
            print("[View] timer state change: \(newValue)")
            if newValue {
                watchOutroViewModel.startTimer()
            }
        }
        .onAppear {
            if connectManager.isTimerRunning {
                watchOutroViewModel.startTimer()
            }
        }
    }
}
