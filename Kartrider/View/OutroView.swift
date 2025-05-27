//
//  OutroView.swift
//  Kartrider
//
//  Created by jiwon on 5/27/25.
//

import SwiftUI

struct OutroView: View {

    @Binding var path: NavigationPath

    var body: some View {
        VStack {
            Text("결말페이지")
            Text("홈으로").onTapGesture {
                path.removeLast(path.count)
            }
        }
    }
}

#Preview {
    OutroView(path: .constant(NavigationPath()))
}
