//
//  EndingView.swift
//  Kartrider
//
//  Created by 박난 on 5/28/25.
//

import SwiftUI

struct EndingView: View {

    @EnvironmentObject private var coordinator: NavigationCoordinator

    var body: some View {
        NavigationBarWrapper(
            navStyle: NavigationBarStyle.historyDetail,
            onTapLeft: { coordinator.pop() }
        ) {
            VStack {
                Spacer()
                Text("[[전체 이야기 보기]]").onTapGesture {
                    coordinator.push(.endingDetail)
                }
                Text("[[다른 결말 시도(소개 화면)]]").onTapGesture {
                    coordinator.push(.intro)

                }
                Spacer()
            }
        }
        .background(Color.brown)
    }
}

#Preview {
    EndingView()
        .environmentObject(NavigationCoordinator())
}
