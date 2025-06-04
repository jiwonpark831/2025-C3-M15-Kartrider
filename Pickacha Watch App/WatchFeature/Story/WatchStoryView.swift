//
//  WatchStoryView.swift
//  Pickacha Watch App
//
//  Created by jiwon on 5/31/25.
//

import SwiftUI

struct WatchStoryView: View {

    @EnvironmentObject private var coordinator: WatchNavigationCoordinator
    @StateObject private var viewModel = WatchStoryViewModel()

    var body: some View {
        switch viewModel.storyNodeType {
        case .exposition: ExpositionView()
        case .decision: DecisionView()
        case .ending: WatchOutroView()
        default: Text("error")
        }
    }
}
