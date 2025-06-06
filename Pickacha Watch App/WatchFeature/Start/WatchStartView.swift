//
//  WatchStartView.swift
//  Pickacha Watch App
//
//  Created by jiwon on 5/31/25.
//

import AVFoundation
import SwiftUI

struct WatchStartView: View {
    @EnvironmentObject private var connectManager: WatchConnectManager
    @EnvironmentObject private var coordinator: WatchNavigationCoordinator
    @StateObject private var watchStartViewModel: WatchStartViewModel

    init(connectManager: WatchConnectManager) {
        _watchStartViewModel = StateObject(
            wrappedValue: WatchStartViewModel(
                watchConnectivityManager: connectManager))
    }

    var body: some View {
        VStack {
            if !watchStartViewModel.isStart {
                Text("이야기를 감상하려면 iPhone에서 앱을 실행해 주세요.")
                    .onAppear {
                        watchStartViewModel.speakIntro()
                    }
            } else {
                Color.clear.onAppear {
                    coordinator.push(.story)
                }
            }
        }
        .onChange(of: connectManager.startContent) { newValue in
            watchStartViewModel.isStart = newValue
        }
    }
}
