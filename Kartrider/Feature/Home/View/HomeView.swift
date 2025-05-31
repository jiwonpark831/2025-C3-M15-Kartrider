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
            VStack(spacing: 24) {
                headerSection
                
                
                List(viewModel.contents, id: \.id) { content in
                    Text(content.title)
                        .onTapGesture {
                            coordinator.push(Route.intro(content))
                        }
                }
                
            }
        }
        .task {
            viewModel.loadContents(context: context)
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 4) {
            Group {
                Text("선택에 따라 바뀌는 결말!")
                Text("내가 만드는 스토리")
            }
            .font(.title2)
            .bold()
            .foregroundColor(Color.textPrimary)
        }
    }
    
//    private var carouselSection: some View {
//        TabView(section: $currentPage) {
//            ForEach(viewModel.contents.indices, id: \.self) { index in
//                
//            }
//        }
//    }
    
    
}

#Preview {
    HomeView()
        .environmentObject(NavigationCoordinator())
}
