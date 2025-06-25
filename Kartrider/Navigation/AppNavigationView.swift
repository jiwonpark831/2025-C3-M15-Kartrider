//
//  AppNavigationView.swift
//  Kartrider
//
//  Created by J on 5/28/25.
//

import SwiftUI

// MARK: 제발 개행을 신경써!!!!!
struct AppNavigationView: View {
    
    @StateObject var coordinator = NavigationCoordinator()
    @StateObject private var ttsManager = TTSManager()
    @EnvironmentObject private var iosConnectManager: IosConnectManager
    
    var body: some View {
        NavigationStack(path: $coordinator.paths) {
            HomeView()
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .home:
                        HomeView()
                    case .intro(let content):
                        IntroView(content: content)
                    case .story(let title, let id):
                        StoryView(title: title, id: id)
                    case .tournament(let title, let id):
                        TournamentView(title: title, id: id)
                    case .outro:
                        OutroView()
                    case .storage:
                        StorageView()
                    case .history:
                        HistoryView()
                    case .historyTimeline:
                        HistoryTimelineView()
                    }
                }
        }
        .environmentObject(coordinator)
        .environmentObject(ttsManager)
    }
}

#Preview {
    AppNavigationView()
}
