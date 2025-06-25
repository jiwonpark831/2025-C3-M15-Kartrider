//
//  NavigationCoordinator.swift
//  Kartrider
//
//  Created by J on 5/28/25.
//

import Foundation

class NavigationCoordinator: ObservableObject {
    // MARK: - 왜 paths죠?
    @Published var paths: [Route] = []

    func push(_ path: Route) {
        paths.append(path)
    }

    func pop() {
        paths.removeLast()
    }

    func popToRoot() {
        paths.removeAll()
    }
}
// MARK: 제발 개행에 신경을써
