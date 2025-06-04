//
//  DecisionView.swift
//  Pickacha Watch App
//
//  Created by jiwon on 6/2/25.
//

import SwiftUI

struct DecisionView: View {

    @StateObject private var viewModel = DecisionViewModel()

    var body: some View {
        if viewModel.isFirstRequest {
            if viewModel.isStartTimer {
                VStack {
                    Text("손목을 돌려서 선택")
                    ZStack {
                        Circle()
                            .trim(from: 0, to: viewModel.progress)
                            .stroke(
                                Color.orange,
                                style: StrokeStyle(
                                    lineWidth: 6, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                            .frame(width: 165, height: 165)
                            .animation(
                                .linear(duration: 10), value: viewModel.progress
                            )
                        Text("\(viewModel.time)").onAppear {
                            viewModel.startTimer()
                        }
                    }
                    HStack {
                        Text("1번").foregroundStyle(
                            viewModel.choice == "1번"
                                ? Color.orange : Color.white)
                        Spacer()
                        Text("2번").foregroundStyle(
                            viewModel.choice == "2번"
                                ? Color.orange : Color.white)
                    }
                }.onAppear {
                    viewModel.startTimer()
                    viewModel.progress = 1.0
                    viewModel.makeChoice()
                }
            } else {
                ZStack {
                    Circle()
                        .trim(from: 0, to: viewModel.progress)
                        .stroke(
                            Color.orange,
                            style: StrokeStyle(lineWidth: 6, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .frame(width: 165, height: 165)
                        .animation(
                            .linear(duration: 5), value: viewModel.progress)

                    VStack(spacing: 16) {
                        Text("선택지가\n재생중입니다")
                            .font(.system(size: 20, weight: .bold))
                            .multilineTextAlignment(.center)

                    }
                }
                .onAppear {
                    viewModel.progress = 1.0
                }
            }
        } else {
            if viewModel.isStartTimer {
                VStack {
                    Text("손목을 돌려서 선택")
                    ZStack {
                        Circle()
                            .trim(from: 0, to: viewModel.progress)
                            .stroke(
                                Color.orange,
                                style: StrokeStyle(
                                    lineWidth: 6, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                            .frame(width: 165, height: 165)
                            .animation(
                                .linear(duration: 10), value: viewModel.progress
                            )
                        Text("\(viewModel.time)").onAppear {
                            viewModel.startTimer()
                        }
                    }
                    HStack {
                        Text("1번").foregroundStyle(
                            viewModel.choice == "1번"
                                ? Color.orange : Color.white)
                        Spacer()
                        Text("2번").foregroundStyle(
                            viewModel.choice == "2번"
                                ? Color.orange : Color.white)
                    }
                }.onAppear {
                    viewModel.startTimer()
                    viewModel.progress = 1.0
                    viewModel.makeChoice()
                }
            } else {
                if viewModel.isStartTimer {
                    ZStack {
                        Circle()
                            .trim(from: 0, to: viewModel.progress)
                            .stroke(
                                Color.orange,
                                style: StrokeStyle(
                                    lineWidth: 6, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                            .frame(width: 165, height: 165)
                            .animation(
                                .linear(duration: 5), value: viewModel.progress)

                        VStack(spacing: 16) {
                            Text("선택지가\n재생중입니다")
                                .font(.system(size: 20, weight: .bold))
                                .multilineTextAlignment(.center)

                        }
                    }
                    .onAppear {
                        viewModel.progress = 1.0
                    }
                } else {
                    ZStack {
                        Circle()
                            .trim(from: 0, to: viewModel.progress)
                            .stroke(
                                Color.orange,
                                style: StrokeStyle(
                                    lineWidth: 6, lineCap: .round)
                            )
                            .rotationEffect(.degrees(-90))
                            .frame(width: 165, height: 165)
                            .animation(
                                .linear(duration: 5), value: viewModel.progress)

                        VStack(spacing: 10) {
                            Text("선택되지 않음")
                                .font(.system(size: 20, weight: .bold))
                            Text("선택지가 다시 한번 \n재생됩니다")
                                .font(.system(size: 18))
                                .multilineTextAlignment(.center)
                                .foregroundColor(.gray)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .onAppear {
                        viewModel.progress = 1.0
                    }
                }
            }

        }
    }

}

#Preview {
    DecisionView()
}
