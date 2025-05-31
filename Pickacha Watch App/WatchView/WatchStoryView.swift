//
//  WatchStoryView.swift
//  Pickacha Watch App
//
//  Created by jiwon on 5/31/25.
//

import SwiftUI

struct WatchStoryView: View {

    @EnvironmentObject private var coordinator: WatchNavigationCoordinator

    var body: some View {
        Text("storyview네비게이션 확인용 버튼").onTapGesture {
            coordinator.push(.outro)
        }
    }
}

#Preview {
    WatchStoryView()
}
