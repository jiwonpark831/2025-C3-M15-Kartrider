//
//  WatchNavigationCoordinator.swift
//  Pickacha Watch App
//
//  Created by jiwon on 5/31/25.
//

import Foundation

class WatchNavigationCoordinator: ObservableObject {
    @Published var paths: [WatchRoute] = []

    func push(_ path: WatchRoute) {
        paths.append(path)
    }

    func pop() {
        paths.removeLast()
    }

    func popToRoot() {
        paths.removeAll()
    }
}
