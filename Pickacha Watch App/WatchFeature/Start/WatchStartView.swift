//
//  WatchStartView.swift
//  Pickacha Watch App
//
//  Created by jiwon on 5/31/25.
//

import AVFoundation
import SwiftUI

struct WatchStartView: View {
    // TODO: connectManager -> 객체를 분리하자
    @EnvironmentObject private var connectManager: WatchConnectManager
    @EnvironmentObject private var coordinator: WatchNavigationCoordinator
    @StateObject private var watchStartViewModel: WatchStartViewModel
    
    // TODO: init 제거
    init(connectManager: WatchConnectManager) {
        _watchStartViewModel = StateObject(
            wrappedValue: WatchStartViewModel(
                watchConnectivityManager: connectManager))
    }
    
    var body: some View {
        VStack {
            if !watchStartViewModel.isStart {
                VStack {
                    Image(systemName: "book.fill")
                        .font(.system(.headline))
                        .foregroundColor(.white)
                    Spacer()
                        .frame(height: 9)
                    Group {
                        Text("이야기를 감상하려면")
                        Text("iPhone에서")
                        Text("앱을 실행해 주세요.")
                    }.font(.system(.headline))
                        .foregroundColor(.white)
                }
                .onAppear {
                    watchStartViewModel.speakIntro()
                }
            } else {
                Color.clear
                    .onAppear {
                    coordinator.push(.story)
                }
            }
        }
        // TODO: ViewModel에서 처리하도록 변경
        .onChange(of: connectManager.hasStartedContent) { newValue in
            watchStartViewModel.isStart = newValue
        }
    }
}
