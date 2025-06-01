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

    init(title: String, id: String) {
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
                    Text(errorMessage)

                case .success(let storyNode):
                    VStack {
                        Divider()
                        Spacer().frame(height: 28)

                        DescriptionBoxView(text: storyNode.text)

                        nodeTypeView(for: storyNode)

                        Spacer()

                        Button {
                            if ttsManager.isSpeaking {
                                ttsManager.pause()
                            } else {
                                ttsManager.resume()
                            }
                        } label: {
                            Image(systemName: ttsManager.isSpeaking ? "pause.fill" : "play.fill")
                                .font(.system(size: 36))
                                .foregroundColor(.textPrimary)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if !isTransitioning {
                            isTransitioning = true
                            ttsManager.stop()
                            viewModel.goToNextNode(from: storyNode)
                        }
                    }
                }
            }
        }
        .task {
            await viewModel.loadStoryNode(context: context)
        }
        .onChange(of: viewModel.state) {
            guard case .success(let storyNode) = viewModel.state else { return }

            isTransitioning = false
            ttsManager.stop()

            ttsManager.onFinish = {
                if !isTransitioning {
                    isTransitioning = true
                    viewModel.goToNextNode(from: storyNode)
                }
            }

            Task {
                try await Task.sleep(for: .milliseconds(500))
                if !ttsManager.isSpeaking {
                    ttsManager.speak(storyNode.text)
                }
            }
        }
    }

    @ViewBuilder
    private func nodeTypeView(for storyNode: StoryNode) -> some View {
        switch storyNode.type {
        case .exposition:
            EmptyView()

        case .decision:
            VStack(spacing: 12) {
                DecisionBoxView(
                    text: storyNode.choiceA?.text ?? "",
                    storyChoiceOption: .a,
                    toId: storyNode.choiceA?.toId ?? ""
                )
                DecisionBoxView(
                    text: storyNode.choiceB?.text ?? "",
                    storyChoiceOption: .b,
                    toId: storyNode.choiceB?.toId ?? ""
                )
            }

        case .ending:
            Text("엔딩입니다.")
                .font(.title)
        }
    }
}

