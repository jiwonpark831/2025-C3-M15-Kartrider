//
//  HomeView.swift
//  Kartrider
//
//  Created by jiwon on 5/27/25.
//

import SwiftUI

struct HomeView: View {

    @Binding var path: NavigationPath

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    path.append(Route.storage)
                } label: {
                    Image(systemName: "book")
                        .font(.title)
                        .foregroundColor(.black)
                        .padding()
                }
            }
            Spacer()
            Text("[[대표 스토리 썸네일]]").onTapGesture {
                path.append(Route.intro)
            }
            Spacer()
        }
    }
}

#Preview {
    HomeView(path: .constant(NavigationPath()))
}
