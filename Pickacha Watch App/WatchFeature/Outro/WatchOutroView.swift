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
    @StateObject private var viewModel = WatchOutroViewModel()

    var body: some View {
        if viewModel.isEndingPlay {
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
        } else {
            VStack {
                ZStack {
                    Circle()
                        .trim(from: 1 - viewModel.progress, to: 1)
                        .stroke(
                            Color.orange,
                            style: StrokeStyle(
                                lineWidth: 2, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .frame(width: 73, height: 73)
                        .animation(
                            .linear(duration: 1),
                            value: viewModel.progress
                        )
                    Text("\(viewModel.time)").font(
                        .system(size: 30, weight: .light))
                }
                Spacer().frame(height: 14)
                Group {
                    Text("10초 후")
                    Text("다음 이야기가 재생됩니다.")
                }
                .font(.system(size: 10, weight: .regular))
            }.onAppear {
                viewModel.startTimer()
            }
        }
    }
}

#Preview {
    WatchOutroView()
}
