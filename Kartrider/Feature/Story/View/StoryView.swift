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
    @StateObject private var storyViewModel: StoryViewModel
    @StateObject private var ttsViewModel = TTSViewModel()
    let title: String

    init(title: String, id: String) {
        _storyViewModel = StateObject(wrappedValue: StoryViewModel(title: title, id: id))
        self.title = title
    }

    var body: some View {
        NavigationBarWrapper(
            navStyle: NavigationBarStyle.play(title: title),
            onTapLeft: { coordinator.pop() }
        ) {
            Group {
                if storyViewModel.isLoading {
                    Spacer()
                    ProgressView()
                    Spacer()
                } else if let errorMessage = storyViewModel.errorMessage {
                    Text(errorMessage)
                } else if let storyNode = storyViewModel.currentNode {
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
                            storyViewModel.goToNextNode(from: storyNode)
                        }
                    }
                }
            }
        }
        .task {
            await storyViewModel.loadInitialNode(context: context)
        }
        .onChange(of: storyViewModel.currentNode) { oldNode, newNode in
            guard let storyNode = newNode else { return }

            Task {
                try? await Task.sleep(for: .milliseconds(300))

                await ttsViewModel.speakSequentially(storyNode.text)

                if storyNode.type == .decision,
                   let a = storyNode.choiceA, let b = storyNode.choiceB {
                    await ttsViewModel.speakSequentially("A")
                    await ttsViewModel.speakSequentially(a.text)
                    await ttsViewModel.speakSequentially("B")
                    await ttsViewModel.speakSequentially(b.text)
                }

                if storyNode.type == .exposition {
                    storyViewModel.goToNextNode(from: storyNode)
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
                if let choiceA = storyNode.choiceA, let choiceB = storyNode.choiceB {
                    Button {
                        ttsViewModel.reset()
                        storyViewModel.selectChoice(toId: choiceA.toId)
                    } label: {
                        DecisionBoxView(text: choiceA.text, storyChoiceOption: .a, toId: choiceA.toId)
                    }
                    Button {
                        ttsViewModel.reset()
                        storyViewModel.selectChoice(toId: choiceB.toId)
                    } label: {
                        DecisionBoxView(text: choiceB.text, storyChoiceOption: .b, toId: choiceB.toId)
                    }
                }
            }
        case .ending:
            Text("엔딩입니다.").font(.title)
        }
    }
}
