//
//  WatchStoryView.swift
//  Pickacha Watch App
//
//  Created by jiwon on 5/31/25.
//

import SwiftUI

struct WatchStoryView: View {
    // TODO: connectManager : 객체를 분리하자
    @EnvironmentObject private var connectManager: WatchConnectManager
    @EnvironmentObject private var coordinator: WatchNavigationCoordinator
    @StateObject private var watchStoryViewModel: WatchStoryViewModel

    // TODO: init 제거
    init(connectManager: WatchConnectManager) {
        _watchStoryViewModel = StateObject(
            wrappedValue: WatchStoryViewModel(
                watchConnectivityManager: connectManager
            )
        )
    }

    // TODO: 컴포넌트로 분리 - 로직 수정
    var body: some View {
        VStack {
            contentView(for: connectManager.currentStage)
                .id(connectManager.currentStage)
        }
        .onReceive(connectManager.$currentStage) { newStage in
            print("[VIEW] stage updated to '\(newStage)'")
        }
    }

    // TODO: ViewBuilder 제거, 컴포넌트로 분리
    @ViewBuilder
    func contentView(for stage: String) -> some View {
        switch stage {
        case "exposition": ExpositionView(connectManager: connectManager)
        case "decision": DecisionView(connectManager: connectManager)
        case "ending":
            Color.clear.onAppear {
                coordinator.push(.outro)
            }
        default: Text("Loading...")
        }
    }
}
