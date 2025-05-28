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
        Text("[[결말 자세히 보기]]").onTapGesture {
            path.append(Route.endingDetail)
        }
    }
}
