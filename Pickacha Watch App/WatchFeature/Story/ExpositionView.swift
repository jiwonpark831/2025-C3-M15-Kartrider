//
//  ExpositionView.swift
//  Pickacha Watch App
//
//  Created by jiwon on 6/2/25.
//

import SwiftUI

struct ExpositionView: View {

    @State private var isPlay = true

    var body: some View {
        VStack {
            if isPlay {
                Image(systemName: "pause.fill").onTapGesture {
                    isPlay.toggle()
                    print("일시정지")
                }
            } else {
                Image(systemName: "play.fill").onTapGesture {
                    isPlay.toggle()
                    print("재생")
                }
            }
        }
    }
}

#Preview {
    ExpositionView()
}
