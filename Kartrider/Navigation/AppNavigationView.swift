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
                case .intro: IntroView()
                case .story: StoryView()
                case .outro: OutroView()
                case .storage: StorageView()
                case .ending: EndingView()
                case .endingDetail: EndingDetailView()
                }
            }
        }.environmentObject(coordinator)
    }
}

#Preview {
    AppNavigationView()
}
