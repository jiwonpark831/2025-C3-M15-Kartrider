//
//  StoryView.swift
//  Kartrider
//
//  Created by jiwon on 5/27/25.
//

import SwiftUI

struct StoryView: View {

    let content: ContentMeta
    
    @EnvironmentObject private var coordinator: NavigationCoordinator

    var body: some View {
        NavigationBarWrapper(
            navStyle: NavigationBarStyle.play(title: "임의 - 스토리 진행"),
            onTapLeft: { coordinator.pop() }
        ) {
            VStack {
                Spacer()
                Text("선택된 컨텐츠 제목 : \(content.title)")
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
    let dummyContent = ContentMeta(title: "예시 제목", summary: "이건 요약입니다.", type: ContentType.story, hashtags: ["니카", "제이", "지지"])
    
    StoryView(content: dummyContent)
        .environmentObject(NavigationCoordinator())
}
