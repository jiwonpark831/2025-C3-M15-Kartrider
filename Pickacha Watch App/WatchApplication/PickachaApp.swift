//
//  PickachaApp.swift
//  Pickacha Watch App
//
//  Created by jiwon on 5/28/25.
//

import SwiftUI

@main
struct Pickacha_Watch_AppApp: App {

    @StateObject private var watchConnectManager = WatchConnectManager()

    var body: some Scene {
        WindowGroup {
            WatchNavigationView()
                .environmentObject(watchConnectManager)
        }
    }
}
