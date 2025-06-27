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
        ZStack {
            Circle()
                .frame(width: 102, height: 102).foregroundColor(.white)
            Image(
                systemName: expositionViewModel.isPlayTTS
                    ? "pause.fill" : "play.fill"
            ).font(.system(size: 36, weight: .bold))
                .foregroundColor(.orange)
                .onTapGesture {
                    expositionViewModel.toggleStateWatch()
                }
        }
        .onAppear {
            expositionViewModel.syncTTSState()
        }
        .onChange(of: connectManager.isTTSPlaying) { newValue in
            expositionViewModel.updateStateByIos(newValue)
        }
    }
}
