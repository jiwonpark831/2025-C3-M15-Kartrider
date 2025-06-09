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
    @EnvironmentObject private var iosConnectManager: IosConnectManager

    let title: String

    init(title: String, id: String) {
        _storyViewModel = StateObject(
            wrappedValue: StoryViewModel(title: title, id: id))
        self.title = title
    }

    var body: some View {
        NavigationBarWrapper(
            navStyle: NavigationBarStyle.play(title: title),
            onTapLeft: {
                storyViewModel.ttsManager.pause()
                coordinator.pop()
            }
        ) {
            VStack(spacing: 16) {
                Divider()
                Group {
                    if storyViewModel.isLoading {
                        //                    ProgressView().padding()
                        DescriptionBoxView(
                            text: storyViewModel.currentNode?.text ?? "")
                        Spacer()
                    } else if let errorMessage = storyViewModel.errorMessage {
                        Text(errorMessage)
                    } else if let storyNode = storyViewModel.currentNode {
                        VStack {

                            DescriptionBoxView(text: storyNode.text)

                            nodeTypeView(for: storyNode)

                            Spacer()

                            TTSControlButton(isSpeaking: storyViewModel.isSpeaking)
                            {
                                storyViewModel.toggleSpeaking()
                            }
                            .disabled(
                                storyViewModel.isTransitioningTTS
                                    || storyViewModel.isTogglingTTS)
                        }
                        .contentShape(Rectangle())
                    }
                }
            }
            
            
        }
        .task {
            await storyViewModel.loadInitialNode(context: context)
        }
        .onAppear {
            storyViewModel.iosConnectManager = iosConnectManager
            storyViewModel.isSpeaking = iosConnectManager.isPlayTTS
        }
        .onChange(of: iosConnectManager.selectedOption) { newOption in
            guard let selected = newOption else { return }

            print("[DEBUG] 워치 선택 감지: \(selected.rawValue)")
            storyViewModel.handleWatchChoice(option: selected)

            iosConnectManager.selectedOption = nil

        }
        .onChange(of: iosConnectManager.isPlayTTS) { newValue in
            if newValue == storyViewModel.isSpeaking {
                return
            }

            if newValue {
                storyViewModel.ttsManager.resume()
            } else {
                storyViewModel.ttsManager.pause()
            }
            storyViewModel.isSpeaking = newValue
        }
        .onChange(of: storyViewModel.currentNode) { _, newNode in
            guard let storyNode = newNode else { return }
            guard !storyViewModel.isSequenceInProgress else { return }

            Task {
                await MainActor.run {
                    storyViewModel.isSequenceInProgress = true
                }
                try? await Task.sleep(for: .milliseconds(300))
                await storyViewModel.handleStoryNode(
                    storyNode, context: context)
            }
        }
        .onChange(of: iosConnectManager.timeout) { newValue in
            storyViewModel.handleTimeout(newValue)
        }
    }

    @ViewBuilder
    private func nodeTypeView(for storyNode: StoryNode) -> some View {
        switch storyNode.type {
        case .exposition:
            EmptyView()
        case .decision:
            VStack(spacing: 12) {
                if let choiceA = storyNode.choiceA,
                    let choiceB = storyNode.choiceB
                {
                    DecisionBoxView(
                        text: choiceA.text,
                        storyChoiceOption: .a,
                        action: {
                            storyViewModel.selectChoice(toId: choiceA.toId)
                        }
                    )
                    .disabled(storyViewModel.isSequenceInProgress)

                    DecisionBoxView(
                        text: choiceB.text,
                        storyChoiceOption: .b,
                        action: {
                            storyViewModel.selectChoice(toId: choiceB.toId)
                        }
                    )
                    .disabled(storyViewModel.isSequenceInProgress)
                }
            }
        case .ending:
            Text("엔딩입니다.").font(.title)
        }
    }
}

#Preview {
    StoryView(title: "임시 타이틀인데요", id: "")
}
