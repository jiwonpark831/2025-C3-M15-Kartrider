//
//  IntroView.swift
//  Kartrider
//
//  Created by jiwon on 5/27/25.
//

import SwiftUI

struct IntroView: View {

    @EnvironmentObject private var coordinator: NavigationCoordinator
    @StateObject private var viewModel: IntroViewModel
    
    init(content: ContentMeta) {
        _viewModel = StateObject(wrappedValue: IntroViewModel(content: content))
    }

    var body: some View {
        NavigationBarWrapper(
            navStyle: NavigationBarStyle.intro,
            onTapLeft: { coordinator.pop() }
        ) {
            VStack {
                Spacer()
                Text("인트로페이지")
                Text("제목 : \(viewModel.content.title)")
                Text("시작하기").onTapGesture {
                    coordinator.push(Route.story(viewModel.content))
                }
                Spacer()
            }
        }
    }
}

#Preview {
//    IntroView()
//        .environmentObject(NavigationCoordinator())
}
