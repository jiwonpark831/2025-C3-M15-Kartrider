//
//  WatchOutroView.swift
//  Pickacha Watch App
//
//  Created by jiwon on 5/31/25.
//

import SwiftUI

struct WatchOutroView: View {

    @EnvironmentObject private var coordinator: WatchNavigationCoordinator

    var body: some View {
        VStack {
            Text("10초 후 다음 이야기가 재생됩니다.")
            Text("홈버튼").onTapGesture {
                coordinator.popToRoot()
            }
        }
    }
}

#Preview {
    WatchOutroView()
}
