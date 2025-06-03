//
//  DecisionView.swift
//  Pickacha Watch App
//
//  Created by jiwon on 6/2/25.
//

import SwiftUI

struct DecisionView: View {

    @StateObject private var viewModel = DecisionViewModel()

    var body: some View {
        VStack {
            Text("손목을 돌려서 선택")
            ZStack {
                ProgressView().progressViewStyle(.circular)
                Text("\(viewModel.time)").onAppear { viewModel.startTimer() }
            }
            HStack {
                Text("1번").foregroundStyle(
                    viewModel.choice == "1번" ? Color.orange : Color.white)
                Spacer()
                Text("2번").foregroundStyle(
                    viewModel.choice == "2번" ? Color.orange : Color.white)
            }
        }.onAppear {
            viewModel.startTimer()
            viewModel.makeChoice()
        }
    }

}

#Preview {
    DecisionView()
}
