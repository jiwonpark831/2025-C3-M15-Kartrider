//
//  WatchStoryView.swift
//  Pickacha Watch App
//
//  Created by jiwon on 5/31/25.
//

import AVFoundation
import SwiftUI

struct WatchStoryView: View {

    @EnvironmentObject private var coordinator: WatchNavigationCoordinator
    @State private var storyNodeType = "decision"

    var body: some View {
        switch storyNodeType {
        case "exposition":
            ExpositionView()
        case "decision":
            DecisionView()
        case "ending":
            WatchOutroView()
        default:
            VStack {
                Text("default")
            }
        }
    }
}

//#Preview {
//    WatchStoryView()
//        .environmentObject(WatchNavigationCoordinator())
//}
