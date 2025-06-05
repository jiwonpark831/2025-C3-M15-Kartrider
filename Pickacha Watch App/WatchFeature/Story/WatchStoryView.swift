//
//  WatchStoryView.swift
//  Pickacha Watch App
//
//  Created by jiwon on 5/31/25.
//

import SwiftUI

struct WatchStoryView: View {
    @EnvironmentObject private var connectManager: WatchConnectManager
    @EnvironmentObject private var coordinator: WatchNavigationCoordinator
    @StateObject private var watchStoryViewModel: WatchStoryViewModel

    init(connectManager: WatchConnectManager) {
        _watchStoryViewModel = StateObject(
            wrappedValue: WatchStoryViewModel(
                watchConnectivityManager: connectManager))

    }

    var body: some View {
        contentView(for: connectManager.stage)
    }

    @ViewBuilder
    func contentView(for stage: String) -> some View {
        switch stage {
        case "exposition": ExpositionView(connectManager: connectManager)
        case "decision": DecisionView(connectManager: connectManager)
        case "ending": WatchOutroView()
        default: Text("[ERROR] wrong stage")
        }
    }
}
