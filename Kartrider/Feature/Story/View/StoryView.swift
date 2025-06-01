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
                    Text(errorMessage)
                case .success(let storyNode):
                    VStack {
                        Divider()
                        Spacer().frame(height: 28)

                        TextBoxView(text: storyNode.text)

                        Spacer()

                        Button(action: {
                            if ttsManager.isSpeaking {
                                ttsManager.pause()
                            } else {
                                ttsManager.resume()
                            }
                        }) {
                            Image(systemName: ttsManager.isSpeaking ? "pause.fill" : "play.fill")
                                .font(.system(size: 36))
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
        .onChange(of: viewModel.state) { newState in
            guard case .success(let storyNode) = newState else { return }

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
