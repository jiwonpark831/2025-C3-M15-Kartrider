//
//  EndingView.swift
//  Kartrider
//
//  Created by 박난 on 5/28/25.
//

import SwiftUI

struct EndingView: View {
    
    @Binding var path: NavigationPath
    var body: some View {
        Text("[[전체 이야기 보기]]").onTapGesture {
            path.append(Route.endingDetail)
        }
        Text("[[다른 결말 시도(소개 화면)]]").onTapGesture {
            path.removeLast(path.count)
            path.append(Route.intro)
        }
    }
}

#Preview {
    EndingView(path: .constant(NavigationPath()))
}
