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
    let title: String

    init(title: String, id: String) {
        _storyViewModel = StateObject(wrappedValue: StoryViewModel(title: title, id: id))
        self.title = title
    }

    var body: some View {
        NavigationBarWrapper(
            navStyle: NavigationBarStyle.play(title: title),
            onTapLeft: {
                storyViewModel.ttsManager.stop()
                coordinator.pop()
            }
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
                            if storyViewModel.ttsManager.isSpeaking {
                                storyViewModel.ttsManager.pause()
                            } else {
                                storyViewModel.ttsManager.resume()
                            }
                        } label: {
                            Image(systemName: storyViewModel.ttsManager.isSpeaking ? "pause.fill" : "play.fill")
                                .font(.system(size: 36))
                                .foregroundColor(.textPrimary)
                        }
                    }
                    .contentShape(Rectangle())
                }
            }
        }
        .task {
            await storyViewModel.loadInitialNode(context: context)
        }
        .onChange(of: storyViewModel.currentNode) { _, newNode in
            guard let storyNode = newNode else { return }
            
            storyViewModel.isSequenceInProgress = true
            
            Task {
                try? await Task.sleep(for: .milliseconds(300))
                await storyViewModel.handleStoryNode(storyNode)
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
                        storyViewModel.selectChoice(toId: choiceA.toId)
                    } label: {
                        DecisionBoxView(text: choiceA.text, storyChoiceOption: .a, toId: choiceA.toId)
                    }
                    .disabled(storyViewModel.isSequenceInProgress)

                    Button {
                        storyViewModel.selectChoice(toId: choiceB.toId)
                    } label: {
                        DecisionBoxView(text: choiceB.text, storyChoiceOption: .b, toId: choiceB.toId)
                    }
                    .disabled(storyViewModel.isSequenceInProgress)
                }
            }
        case .ending:
            Text("엔딩입니다.").font(.title)
        }
    }
}
