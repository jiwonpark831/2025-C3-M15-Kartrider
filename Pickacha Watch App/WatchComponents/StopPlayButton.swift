//
//  StopPlayButton.swift
//  Pickacha Watch App
//
//  Created by jiwon on 6/1/25.
//

import SwiftUI

struct StopPlayButton: View {

    @State private var isPlay = true

    var body: some View {
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

#Preview {
    StopPlayButton()
}
