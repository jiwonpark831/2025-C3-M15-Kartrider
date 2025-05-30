//
//  HomeView.swift
//  Kartrider
//
//  Created by jiwon on 5/27/25.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @EnvironmentObject private var coordinator: NavigationCoordinator

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    coordinator.push(.storage)
                } label: {
                    Image(systemName: "book")
                        .font(.title)
                        .foregroundColor(.black)
                        .padding()
                }
            }
            Spacer()
            Text("[[대표 스토리 썸네일]]").onTapGesture {
                coordinator.push(.intro)
            }
            Spacer()
        }
    }
}

#Preview {
    HomeView()
}
