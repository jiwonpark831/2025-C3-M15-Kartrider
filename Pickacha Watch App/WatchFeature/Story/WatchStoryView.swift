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
    @State private var storyNodeType = "exposition"

    var body: some View {
        // 상태 전환을 어떻게 하믄 좋을까요..? 아무리 생각해도 이게 최선은 아니거든예..
        switch storyNodeType {
        case "exposition":
            VStack {
                StopPlayButton()
            }
        case "decision":
            VStack {
                VStack {
                    Text("손목을 돌려서 선택")
                    TenSecTimer()
                    HStack {
                        Text("A")
                        Spacer()
                        Text("B")
                    }
                }
            }
        case "ending":
            WatchOutroView()
        default:
            VStack {
                Text("default")
            }
        }
    }
}

#Preview {
    WatchStoryView()
}
