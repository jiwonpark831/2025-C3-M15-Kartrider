//
//  HomeView.swift
//  Kartrider
//
//  Created by jiwon on 5/27/25.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @EnvironmentObject private var coordinator: NavigationCoordinator

    var body: some View {
        NavigationBarWrapper(
            navStyle: NavigationBarStyle.home,
            onTapRight: { coordinator.push(Route.storage) }
        ) {
            VStack {
                Spacer()
                Text("[썸네일 예시]")
                    .onTapGesture {
                        coordinator.push(Route.intro)
                    }
                Spacer()
            }
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(NavigationCoordinator())
}
