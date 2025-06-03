//
//  AppNavigationView.swift
//  Kartrider
//
//  Created by J on 5/28/25.
//

import SwiftUI

struct AppNavigationView: View {

    @ObservedObject private var coordinator = NavigationCoordinator()

    var body: some View {
        NavigationStack(path: $coordinator.paths) {
            HomeView().navigationDestination(for: Route.self) {
                route in
                switch route {
                case .home: HomeView()
                case .intro(let content): IntroView(content: content)
                case .story(let title, let id): StoryView(title: title, id: id)
                case .tournament(let title, let id) :
                    TournamentView(title: title, id: id)
                case .outro: OutroView()
                case .storage: StorageView()
                case .history: HistoryView()
                case .historyTimeline: HistoryTimelineView()
                }
            }
        }.environmentObject(coordinator)
    }
}

#Preview {
    AppNavigationView()
}
