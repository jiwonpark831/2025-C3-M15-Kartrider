//
//  IntroView.swift
//  Kartrider
//
//  Created by jiwon on 5/27/25.
//

import SwiftUI

struct IntroView: View {

    @EnvironmentObject private var coordinator: NavigationCoordinator

    var body: some View {
        NavigationBarWrapper(
            navStyle: NavigationBarStyle.intro,
            onTapLeft: { coordinator.pop() }
        ) {
            VStack {
                Spacer()
                Text("인트로페이지")
                Text("시작하기").onTapGesture {
                    coordinator.push(Route.story)
                }
                Spacer()
            }
        }
    }
}

#Preview {
    IntroView()
        .environmentObject(NavigationCoordinator())
}
