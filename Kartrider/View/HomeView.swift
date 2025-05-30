//
//  HomeView.swift
//  Kartrider
//
//  Created by jiwon on 5/27/25.
//

import SwiftUI

struct HomeView: View {

    @EnvironmentObject private var coordinator: NavigationCoordinator

    var body: some View {
        VStack {
            HStack {
                Button {
                    UserDefaults.standard.removeObject(forKey: "hasSeededStories")
                    print("[SUCCESS] 시딩 상태 초기화 완료 (hasSeededStories 제거됨)")
                } label: {
                    Text("시딩 리셋")
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(8)
                }
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
