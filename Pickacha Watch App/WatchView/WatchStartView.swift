//
//  WatchStartView.swift
//  Pickacha Watch App
//
//  Created by jiwon on 5/31/25.
//

import SwiftUI

struct WatchStartView: View {

    @EnvironmentObject private var coordinator: WatchNavigationCoordinator

    var body: some View {
        VStack {
            Text("이야기를 감상하려면 iPhone에서 앱을 실행해 주세요.")
            Text("네비게이션 테스트용 버튼").onTapGesture {
                coordinator.push(.story)
            }
        }
    }
}

#Preview {
    WatchStartView()
}
