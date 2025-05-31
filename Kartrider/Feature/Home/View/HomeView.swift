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
    @Environment(\.modelContext) private var context
    
    @StateObject private var viewModel = HomeViewModel()

    var body: some View {
        NavigationBarWrapper(
            navStyle: NavigationBarStyle.home,
            onTapRight: { coordinator.push(Route.storage) }
        ) {
            VStack {
                Spacer()
                List(viewModel.contents, id: \.id) { content in
                    Text(content.title)
                        .onTapGesture {
                            coordinator.push(Route.intro(content))
                        }
                }
//                Text("[썸네일 예시]")
//                    .onTapGesture {
//                        coordinator.push(Route.intro())
//                    }
                Spacer()
            }
        }
        .task {
            viewModel.loadContents(context: context)
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(NavigationCoordinator())
}
