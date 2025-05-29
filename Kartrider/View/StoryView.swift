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
        VStack {
            Text("스토리진행페이지")
            Text("임의로 결말페이지로 가는 버튼").onTapGesture {
                coordinator.push(.outro)
            }
        }
    }
}

#Preview {
    StoryView()
}
