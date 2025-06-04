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
                    .trim(from: 0, to: viewModel.progress)
                    .stroke(
                        Color.orange,
                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: 165, height: 165)
                    .animation(.linear(duration: 5), value: viewModel.progress)

                VStack(spacing: 16) {
                    Text("결말이\n재생중입니다")
                        .font(.system(size: 20, weight: .bold))
                        .multilineTextAlignment(.center)

                }
            }
            .onAppear {
                viewModel.progress = 1.0
            }
        } else {
            VStack {
                ZStack {
                    ProgressView().progressViewStyle(.circular)
                    Text("\(viewModel.time)").onAppear {
                        viewModel.startTimer()
                    }
                }
                Text("10초 후 다음 이야기가 재생됩니다.")
            }
        }
    }
}

#Preview {
    WatchOutroView()
}
