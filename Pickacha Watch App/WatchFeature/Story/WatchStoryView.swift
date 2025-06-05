//
//  WatchStoryView.swift
//  Pickacha Watch App
//
//  Created by jiwon on 5/31/25.
//

import SwiftUI

struct WatchStoryView: View {
    
    @EnvironmentObject private var coordinator: WatchNavigationCoordinator
    //    @StateObject private var viewModel = WatchStoryViewModel()
    @ObservedObject var viewModel = WatchConnectManager.shared.watchStoryVM
    
    
    //    var body: some View {
    //        Text("Current stage: \(viewModel.storyNodeType.rawValue)")
    //
    //        switch viewModel.storyNodeType {
    //        case .exposition: ExpositionView()
    //        case .decision: DecisionView(viewModel: WatchConnectManager.shared.watchDecisionVM)
    //        case .ending: WatchOutroView()
    //        default: Text("error")
    //        }
    //    }
    var body: some View {
        contentView(for: viewModel.storyNodeTypeRaw)
    }
    
    @ViewBuilder
    func contentView(for stage: String) -> some View {
        switch stage {
        case "exposition":
            ExpositionView()
        case "decision":
            DecisionView(viewModel: WatchConnectManager.shared.watchDecisionVM)
        case "ending":
            WatchOutroView()
        default:
            Text("idle 또는 알 수 없는 상태")
        }
    }
}
