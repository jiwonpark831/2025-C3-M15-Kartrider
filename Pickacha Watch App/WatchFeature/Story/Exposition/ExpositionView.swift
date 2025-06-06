//
//  ExpositionView.swift
//  Pickacha Watch App
//
//  Created by jiwon on 6/2/25.
//

import SwiftUI

struct ExpositionView: View {
    @EnvironmentObject private var connectManager: WatchConnectManager
    @StateObject private var expositionViewModel: ExpositionViewModel

    init(connectManager: WatchConnectManager) {
        _expositionViewModel = StateObject(
            wrappedValue: ExpositionViewModel(
                watchConnectivityManager: connectManager))

    }

    var body: some View {
        VStack {
            Image(
                systemName: expositionViewModel.isPlayTTS
                    ? "pause.fill" : "play.fill"
            )
            .onTapGesture {
                expositionViewModel.toggleStateWatch()
            }
        }
        .onAppear {
            expositionViewModel.syncTTSState()
        }
        .onChange(of: connectManager.isPlayTTS) { newValue in
            expositionViewModel.updateStateByIos(newValue)
        }
    }
}
