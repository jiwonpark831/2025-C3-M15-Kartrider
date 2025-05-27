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
        Text("홈화면이고요여기썸네일이들어가겠죠?눌러보세요").onTapGesture {
            path.append(Route.intro)
        }
    }
}

#Preview {
    HomeView(path: .constant(NavigationPath()))
}
