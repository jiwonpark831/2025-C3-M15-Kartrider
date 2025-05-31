//
//  StoryView.swift
//  Kartrider
//
//  Created by jiwon on 5/27/25.
//

import SwiftUI

struct StoryView: View {

    @EnvironmentObject private var coordinator: NavigationCoordinator

    var body: some View {
        NavigationBarWrapper(
            navStyle: NavigationBarStyle.play(title: "임의 - 스토리 진행"),
            onTapLeft: { coordinator.pop() }
        ) {
            VStack {
                Spacer()
                Text("스토리 진행 페이지")
                Text("임의로 결말페이지로 가는 버튼")
                    .onTapGesture {
                        coordinator.push(Route.outro)
                    }
                Spacer()
            }
        }
    }
}

#Preview {
    StoryView()
        .environmentObject(NavigationCoordinator())
}
