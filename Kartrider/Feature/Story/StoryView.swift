//
//  StoryView.swift
//  Kartrider
//
//  Created by jiwon on 5/27/25.
//
import SwiftUI

struct StoryView: View {
    @Environment(\.modelContext) private var context
    
    @EnvironmentObject private var coordinator: NavigationCoordinator
    // TODO: iosConnectManager 단일 객체로 관리하기
    @EnvironmentObject private var iosConnectManager: IosConnectManager
    @StateObject private var storyViewModel: StoryViewModel
    
    init(content: ContentMeta) {
        _storyViewModel = StateObject(
            wrappedValue: StoryViewModel(content: content)
        )
    }
    
    var body: some View {
        NavigationBarWrapper(
            navStyle: NavigationBarStyle.play(title: storyViewModel.content.title),
            onTapLeft: {
                storyViewModel.ttsManager.pause()
                coordinator.pop()
            }
        ) {
            VStack(spacing: 16) {
                Divider()
                Group {
                    if storyViewModel.isLoading {
                        DescriptionBoxView(text: storyViewModel.currentNode?.text ?? "")
                        Spacer()
                    } else if let errorMessage = storyViewModel.errorMessage {
                        Text(errorMessage)
                    } else if let storyNode = storyViewModel.currentNode {
                        VStack {
                            
                            DescriptionBoxView(text: storyNode.text)
                            
                            StoryNodeContentView(
                                storyNode: storyNode,
                                isDisabled: storyViewModel.isSequenceInProgress,
                                selectChoice: storyViewModel.selectChoice(toId:),
                                title: storyViewModel.content.title
                            )
                            
                            Spacer()
                            
                            TTSControlButton(isSpeaking: storyViewModel.isSpeaking) {
                                storyViewModel.toggleSpeaking()
                            }
                            // TODO: ViewModel로 분리
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
            // TODO: setConnectManager와 같은 메서드를 ViewModel에 만든 후, 호출
            storyViewModel.iosConnectManager = iosConnectManager
            storyViewModel.isSpeaking = iosConnectManager.isPlayTTS
        }
        // TODO: 곧 망함. or Combine을 활용해보자!
        .onChange(of: iosConnectManager.selectedOption) { newOption in
            guard let selected = newOption else { return }
            
            print("[DEBUG] 워치 선택 감지: \(selected.rawValue)")
            storyViewModel.handleWatchChoice(option: selected)
            
            iosConnectManager.selectedOption = nil
            
        }
        // TODO: 곧 망함. or Combine을 활용해보자!
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
    
    #Preview {
        let contentSample = ContentMeta(
            title: "title sample",
            summary: "summary sample",
            type: .story,
            hashtags: ["test", "test2"],
            thumbnailName: nil
        )
        StoryView(content: contentSample)
    }
}
