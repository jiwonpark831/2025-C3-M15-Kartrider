//
//  StorageView.swift
//  Kartrider
//
//  Created by 박난 on 5/28/25.
//

import SwiftUI

struct StorageView: View {

    @EnvironmentObject private var coordinator: NavigationCoordinator

    var body: some View {
        NavigationBarWrapper(
            navStyle: NavigationBarStyle.archive,
            onTapLeft: { coordinator.pop() }
        ) {
            VStack {
                Spacer()
                Text("[[ 스토리1 ]]")
                    .onTapGesture {
                        coordinator.push(Route.history)
                    }
                Spacer()
            }
        }
    }
}

#Preview {
    StorageView()
        .environmentObject(NavigationCoordinator())
}
