//
//  WatchStoryView.swift
//  Pickacha Watch App
//
//  Created by jiwon on 5/31/25.
//

import SwiftUI

struct WatchStoryView: View {

    @EnvironmentObject private var coordinator: WatchNavigationCoordinator
    @StateObject private var watchStoryViewModel = WatchStoryViewModel()

    // TODO: 컴포넌트로 분리 - 로직 수정
    var body: some View {
        VStack {
            switch watchStoryViewModel.currentStage {
            case "exposition":
                ExpositionView()
            case "decision":
                DecisionView()
            case "ending":
                Color.clear.onAppear {
                    coordinator.push(.outro)
                }
            default: Text("Loading...")
            }
        }.id(watchStoryViewModel.currentStage)
    }
}
