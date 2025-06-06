//
//  DecisionView.swift
//  Pickacha Watch App
//
//  Created by jiwon on 6/2/25.
//

import SwiftUI

struct DecisionView: View {
    @EnvironmentObject private var connectManager: WatchConnectManager
    @StateObject private var decisionViewModel: DecisionViewModel

    init(connectManager: WatchConnectManager) {
        _decisionViewModel = StateObject(
            wrappedValue: DecisionViewModel(
                watchConnectivityManager: connectManager))

    }

    var body: some View {
        Group {
            //            if decisionViewModel.isFirstRequest {
            if decisionViewModel.isStartTimer == true {
                VStack {
                    Text("손목을 돌려서 선택")
                    ZStack {
                        Circle()
                            .trim(from: 0, to: decisionViewModel.progress)
                            .stroke(
                                Color.orange,
                                style: StrokeStyle(
                                    lineWidth: 6, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                            .frame(width: 165, height: 165)
                            .animation(
                                .linear(duration: 10),
                                value: decisionViewModel.progress
                            )
                        Text("\(decisionViewModel.time)")
//                            .onAppear {
//                                decisionViewModel.startTimer()
//                                decisionViewModel.makeChoice()
//                            }
                    }
                    HStack {
                        Text("1번").foregroundStyle(
                            decisionViewModel.choice == "1번"
                                ? Color.orange : Color.white)
                        Spacer()
                        Text("2번").foregroundStyle(
                            decisionViewModel.choice == "2번"
                                ? Color.orange : Color.white)
                    }
                }
            } else {
                ZStack {
                    Circle()
                        .stroke(
                            Color.orange,
                            style: StrokeStyle(lineWidth: 6, lineCap: .round)
                        )
                        .frame(width: 165, height: 165)
                    VStack(spacing: 16) {
                        Text("선택지가\n재생중입니다")
                            .font(.system(size: 20, weight: .bold))
                            .multilineTextAlignment(.center)

                    }
                }
            }
        }.onChange(of: connectManager.timerStarted) { newValue in
            decisionViewModel.isStartTimer = newValue
            if newValue {
                decisionViewModel.startTimer()
                decisionViewModel.makeChoice()
            }
        }
        .onChange(of: connectManager.decisionIndex) { newValue in
            decisionViewModel.decisionIndex = newValue
        }
        .onChange(of: connectManager.isFirstRequest) { newValue in
            decisionViewModel.isFirstRequest = newValue
        }
        //        else {
        //                if decisionViewModel.isStartTimer {
        //                    VStack {
        //                        Text("손목을 돌려서 선택")
        //                        ZStack {
        //                            Circle()
        //                                .trim(from: 0, to: decisionViewModel.progress)
        //                                .stroke(
        //                                    Color.orange,
        //                                    style: StrokeStyle(
        //                                        lineWidth: 6, lineCap: .round)
        //                                )
        //                                .rotationEffect(.degrees(-90))
        //                                .frame(width: 165, height: 165)
        //                                .animation(
        //                                    .linear(duration: 10), value: decisionViewModel.progress
        //                                )
        //                            Text("\(decisionViewModel.time)").onAppear {
        //                                decisionViewModel.startTimer()
        //                            }
        //                        }
        //                        HStack {
        //                            Text("1번").foregroundStyle(
        //                                decisionViewModel.choice == "1번"
        //                                ? Color.orange : Color.white)
        //                            Spacer()
        //                            Text("2번").foregroundStyle(
        //                                decisionViewModel.choice == "2번"
        //                                ? Color.orange : Color.white)
        //                        }
        //                    }.onAppear {
        //                        decisionViewModel.startTimer()
        //                        decisionViewModel.progress = 1.0
        //                        decisionViewModel.makeChoice()
        //                    }
        //                } else {
        //                    if decisionViewModel.isStartTimer {
        //                        ZStack {
        //                            Circle()
        //                                .trim(from: 0, to: decisionViewModel.progress)
        //                                .stroke(
        //                                    Color.orange,
        //                                    style: StrokeStyle(
        //                                        lineWidth: 6, lineCap: .round)
        //                                )
        //                                .rotationEffect(.degrees(-90))
        //                                .frame(width: 165, height: 165)
        //                                .animation(
        //                                    .linear(duration: 5), value: decisionViewModel.progress)
        //
        //                            VStack(spacing: 16) {
        //                                Text("선택지가\n재생중입니다")
        //                                    .font(.system(size: 20, weight: .bold))
        //                                    .multilineTextAlignment(.center)
        //
        //                            }
        //                        }
        //                        .onAppear {
        //                            decisionViewModel.progress = 1.0
        //                        }
        //                    } else {
        //                        ZStack {
        //                            Circle()
        //                                .trim(from: 0, to: decisionViewModel.progress)
        //                                .stroke(
        //                                    Color.orange,
        //                                    style: StrokeStyle(
        //                                        lineWidth: 6, lineCap: .round)
        //                                )
        //                                .rotationEffect(.degrees(-90))
        //                                .frame(width: 165, height: 165)
        //                                .animation(
        //                                    .linear(duration: 5), value: decisionViewModel.progress)
        //
        //                            VStack(spacing: 10) {
        //                                Text("선택되지 않음")
        //                                    .font(.system(size: 20, weight: .bold))
        //                                Text("선택지가 다시 한번 \n재생됩니다")
        //                                    .font(.system(size: 18))
        //                                    .multilineTextAlignment(.center)
        //                                    .foregroundColor(.gray)
        //                                    .fixedSize(horizontal: false, vertical: true)
        //                            }
        //                        }
        //                        .onAppear {
        //                            decisionViewModel.progress = 1.0
        //                        }
        //                    }
        //                }
        //
        //            }
        //        }
    }
}
