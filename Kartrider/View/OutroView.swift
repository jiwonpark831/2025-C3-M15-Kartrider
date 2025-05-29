//
//  OutroView.swift
//  Kartrider
//
//  Created by jiwon on 5/27/25.
//

import SwiftUI

struct OutroView: View {

    @EnvironmentObject private var coordinator: NavigationCoordinator

    var body: some View {
        VStack {
            Text("결말페이지")
            Text("홈으로").onTapGesture {
                coordinator.popToRoot()
            }
        }
    }
}

#Preview {
    OutroView()
}
