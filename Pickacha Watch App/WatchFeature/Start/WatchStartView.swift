//
//  WatchStartView.swift
//  Pickacha Watch App
//
//  Created by jiwon on 5/31/25.
//

import AVFoundation
import SwiftUI

struct WatchStartView: View {

    @EnvironmentObject private var coordinator: WatchNavigationCoordinator
//        @StateObject private var viewModel = WatchStartViewModel()
    @ObservedObject private var viewModel = WatchConnectManager.shared
        .watchStartVM

    var body: some View {
//        VStack {
//            if !viewModel.isStart {
//                Text("이야기를 감상하려면 iPhone에서 앱을 실행해 주세요.")
//                    .onAppear {
//                        viewModel.speakIntro()
//                        //                        WatchConnectManager.shared.watchStartVM = self.viewModel
//                    }
//            } else {
//                Color.clear.onAppear {
//                    coordinator.push(.story)
//                }
//            }
//
//        }
        VStack {
                    if !viewModel.isStart {
                        Text("이야기를 감상하려면 iPhone에서 앱을 실행해 주세요.")
                            .onAppear {
                                viewModel.speakIntro()
                            }
                    } else {
                        Color.clear
                    }
                }
                .onChange(of: viewModel.isStart) { newValue in
                    if newValue {
                        coordinator.push(.story)
                    }
                }
    }

}

#Preview {
    WatchStartView()
}
