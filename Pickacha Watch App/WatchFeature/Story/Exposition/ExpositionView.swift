//
//  ExpositionView.swift
//  Pickacha Watch App
//
//  Created by jiwon on 6/2/25.
//

import SwiftUI

struct ExpositionView: View {

    @StateObject private var viewModel = ExpositionViewModel()

    var body: some View {
        VStack {
            Image(systemName: viewModel.isPlay ? "pause.fill" : "play.fill")
                .onTapGesture {
                    viewModel.toggleState()
                }
        }
    }
}
#Preview {
    ExpositionView()
}
