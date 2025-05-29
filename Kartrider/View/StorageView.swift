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
        Text("[[이야기 1]]").onTapGesture {
            coordinator.push(.ending)

        }
        Text("이야기 2")
    }
}

#Preview {
    StorageView()
}
