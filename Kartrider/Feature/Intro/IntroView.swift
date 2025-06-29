//  IntroView.swift
//  Kartrider
//
//  Created by jiwon on 5/27/25.
//

import SwiftUI

// TODO: 컴포넌트 분리
struct IntroView: View {
    @Environment(\.modelContext) private var context
    
    @EnvironmentObject private var coordinator: NavigationCoordinator
    // TODO: 객체 ViewModel에서 생성
    @EnvironmentObject private var iosConnectManager: IosConnectManager
    @StateObject private var viewModel: IntroViewModel

    // TODO: init 제거 -> 어떻게 제거해요? content를 넘겨줘야하는데!!!
    init(content: ContentMeta) {
        _viewModel = StateObject(wrappedValue: IntroViewModel(content: content))
    }

    var body: some View {
        NavigationBarWrapper(
            navStyle: NavigationBarStyle.intro,
            onTapLeft: { coordinator.pop() }
        ) {
            VStack(spacing: 16) {

                IntroThumbnailView(content: viewModel.content)

                Divider()
                    .frame(width: 360)

                IntroDescriptionView(content: viewModel.content)

                OrangeButton(title: "이야기 시작하기") { // TODO: - 로직 vm으로 옮기기

                    iosConnectManager.sendStageIdle()

                    switch viewModel.content.type {
                    case .story:
                        if let startNodeId = viewModel.content.story?.startNodeId {
                            coordinator.push(
                                Route.story(viewModel.content.title, startNodeId))
                        } else {
                            print("[ERROR] 스토리가 존재하지 않음")
                        }
                    case .tournament:
                        if let id = viewModel.content.tournament?.id {
                            coordinator.push(Route.tournament(viewModel.content))
                        } else {
                            print("[ERROR] 토너먼트가 존재하지 않음")
                        }
                    }
                }
                .padding(.vertical, 20)
            }
        }
    }
}

#Preview {
    let sample = ContentMeta(
        title: "눈 떠보니 내가 T1 페이커?!",
        summary: "2025 월즈가 코 앞인데 아이언인 내가 어느날 눈 떠보니 페이커 몸에 들어와버렸다.",
        type: .story,
        hashtags: ["빙의", "LOL", "고트"],
        thumbnailName: nil
    )

    return IntroView(content: sample)
        .environmentObject(NavigationCoordinator())
}
