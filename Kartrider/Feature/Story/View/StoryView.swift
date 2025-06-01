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
    @StateObject private var ttsViewModel = TTSViewModel()
    let title: String

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
                if viewModel.isLoading {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                } else if let storyNode = viewModel.currentNode {
                    VStack {
                        Divider()
                        Spacer().frame(height: 28)

                        DescriptionBoxView(text: storyNode.text)

                        nodeTypeView(for: storyNode)

                        Spacer()

                        Button {
                            if ttsViewModel.isSpeaking {
                                ttsViewModel.pause()
                            } else {
                                ttsViewModel.resume()
                            }
                        } label: {
                            Image(systemName: ttsViewModel.isSpeaking ? "pause.fill" : "play.fill")
                                .font(.system(size: 36))
                                .foregroundColor(.textPrimary)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if storyNode.type == .exposition {
                            ttsViewModel.stop()
                            viewModel.goToNextNode(from: storyNode)
                        }
                    }
                }
            }
        }
        .task {
            await viewModel.loadInitialNode(context: context)
        }
        .onChange(of: viewModel.currentNode) { storyNode in
            guard let storyNode else { return }

            ttsViewModel.onFinish = { [weak viewModel] in
                guard let node = viewModel?.currentNode else { return }
                if node.id == storyNode.id && node.type != .decision {
                    viewModel?.goToNextNode(from: node)
                }
            }


            Task {
                try? await Task.sleep(for: .milliseconds(500))
                ttsViewModel.speak(storyNode.text)
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
                if let choiceA = storyNode.choiceA, let choiceB = storyNode.choiceB {
                    DecisionBoxView(text: choiceA.text, storyChoiceOption: .a, toId: choiceA.toId) { toId in
                        ttsViewModel.stop()
                        viewModel.selectChoice(toId: toId)
                    }
                    DecisionBoxView(text: choiceB.text, storyChoiceOption: .b, toId: choiceB.toId) { toId in
                        ttsViewModel.stop()
                        viewModel.selectChoice(toId: toId)
                    }
                }
            }
        case .ending:
            Text("엔딩입니다.").font(.title)
        }
    }
}
