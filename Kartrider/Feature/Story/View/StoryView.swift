//
//  StoryView.swift
//  Kartrider
//
//  Created by jiwon on 5/27/25.
//

import SwiftUI

struct StoryView: View {
    @EnvironmentObject private var coordinator: NavigationCoordinator
    @Environment(\.modelContext) private var context
    @StateObject private var viewModel: StoryViewModel
    let title: String
    
    @StateObject private var ttsManager = TTSManager()
    @State private var isTransitioning = false
    
    init(title: String, id: String){
        _viewModel = StateObject(wrappedValue: StoryViewModel(title: title, id: id))
        self.title = title
    }

    var body: some View {
        NavigationBarWrapper(
            navStyle: NavigationBarStyle.play(title: title),
            onTapLeft: { coordinator.pop() }
        ) {
            Group {
                switch viewModel.state {
                case .loading:
                    Spacer()
                    ProgressView()
                    Spacer()
                case .failure(let errorMessage):
                    Text("\(errorMessage)")
                case .success(let storyNode):
                    VStack {
                        Divider()
                        Spacer()
                            .frame(height: 28)
                        TextBoxView(text: storyNode.text)
                        Spacer()
                        Image(systemName: "pause.fill")
                            .font(.system(size: 36))
                    }
                    .gesture(
                        TapGesture().onEnded {
                            if case .success(let storyNode) = viewModel.state {
                                if !isTransitioning {
                                    isTransitioning = true
                                    ttsManager.stop()
                                    viewModel.goToNextNode(from: storyNode)
                                }
                            }
                        }
                    )
                }
            }
        }
        .task {
            await viewModel.loadStoryNode(context: context)
        }
        .onChange(of: viewModel.state) {
            if case .success(let storyNode) = viewModel.state {
                isTransitioning = false
                
                ttsManager.onFinish = {
                    if !isTransitioning {
                        isTransitioning = true
                        viewModel.goToNextNode(from: storyNode)
                    }
                }
                
                Task {
                    try await Task.sleep(for: .milliseconds(500))
                    ttsManager.speak(storyNode.text)
                }
                
            }
        }
    }
}

//#Preview {
//    let dummyContent = ContentMeta(title: "예시 제목", summary: "이건 요약입니다.", type: ContentType.story, hashtags: ["니카", "제이", "지지"])
//    
//    StoryView(content: dummyContent)
//        .environmentObject(NavigationCoordinator())
//}
