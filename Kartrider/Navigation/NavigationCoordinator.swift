//
//  NavigationCoordinator.swift
//  Kartrider
//
//  Created by J on 5/28/25.
//

import Foundation

class NavigationCoordinator: ObservableObject {
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
