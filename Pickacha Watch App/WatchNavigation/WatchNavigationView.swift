//
//  WatchNavigationView.swift
//  Pickacha Watch App
//
//  Created by jiwon on 5/31/25.
//

import SwiftUI

struct WatchNavigationView: View {
    @EnvironmentObject private var watchConnectManager: WatchConnectManager
    @StateObject private var coordinator = WatchNavigationCoordinator()

    var body: some View {
        NavigationStack(path: $coordinator.paths) {
            WatchStartView(connectManager: watchConnectManager)
                .navigationDestination(for: WatchRoute.self) {
                    route in
                    switch route {
                    case .start:
                        WatchStartView(connectManager: watchConnectManager)
                    case .story:
                        WatchStoryView(connectManager: watchConnectManager)
                    case .outro:
                        WatchOutroView(connectManager: watchConnectManager)
                    }
                }
        }
        .environmentObject(coordinator)
    }
}

#Preview {
    WatchNavigationView()
}
