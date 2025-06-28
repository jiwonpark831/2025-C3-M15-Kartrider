//
//  WatchStoryViewModel.swift
//  Pickacha Watch App
//
//  Created by jiwon on 6/1/25.
//

import Combine
import Foundation

class WatchStoryViewModel: ObservableObject {

    let connectManager = WatchConnectManager.shared
    // MARK: 시간되면 ENUM 타입으로 변경 -> Gigi: enum type으로 변경하니까 값이 잘 전달이 안돼서 일단 string으로 두었습니다

    private var cancellable = Set<AnyCancellable>()

    @Published var currentStage: String = "idle"

    init() {
        connectManager.$currentStage
            .receive(on: DispatchQueue.main)
            .assign(to: \.currentStage, on: self)
            .store(in: &cancellable)
    }
}
