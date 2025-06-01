//
//  WatchOutroView.swift
//  Pickacha Watch App
//
//  Created by jiwon on 5/31/25.
//

import AVFoundation
import SwiftUI

struct WatchOutroView: View {

    @EnvironmentObject private var coordinator: WatchNavigationCoordinator

    var body: some View {
        VStack {
            TenSecTimer()
            Text("10초 후 다음 이야기가 재생됩니다.")
        }
    }
}

#Preview {
    WatchOutroView()
}
