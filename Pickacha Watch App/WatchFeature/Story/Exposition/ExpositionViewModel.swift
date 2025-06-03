//
//  ExpositionViewModel.swift
//  Pickacha Watch App
//
//  Created by jiwon on 6/3/25.
//

import Foundation

class ExpositionViewModel: ObservableObject {
    @Published var isPlay = true

    func toggleState() {
        isPlay.toggle()
        print(isPlay ? "재생" : "일시정지")
    }
}
