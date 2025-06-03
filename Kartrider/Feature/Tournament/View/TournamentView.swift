//
//  TournamentView.swift
//  Kartrider
//
//  Created by J on 6/2/25.
//

import SwiftUI
import SwiftData

struct TournamentView: View {
    @EnvironmentObject private var coordinator: NavigationCoordinator
    @Environment(\.modelContext) private var context
    @StateObject private var viewModel: TournamentViewModel
    
    let title: String
    let id: UUID
    
    init(title: String, id: UUID) {
        _viewModel = StateObject(wrappedValue: TournamentViewModel(tournamentId: id))
        self.title = title
        self.id = id
    }
    
    var body: some View {
        NavigationBarWrapper(
            navStyle: .play(title: title),
            onTapLeft: { coordinator.pop() }
        ) {
            contentBody
        }
        .task {
            viewModel.loadTournament(context: context)
        }
        .onChange(of: viewModel.isFinished) { isFinished in
            guard isFinished else { return }
            viewModel.finishTournamentAndSave(context: context)
        }
    }
    
    @ViewBuilder
    private var contentBody: some View {
        VStack(spacing: 24) {
            if viewModel.isFinished {
                if let winner = viewModel.winner {
                    TournamentResultView(winner: winner.name) {
                        coordinator.popToRoot()
                    }
                }
            }
            else if let (a, b) = viewModel.currentCandidates {
                TournamentMatchView(
                    roundDescription: viewModel.currentRoundDescription,
                    a: a.name,
                    b: b.name,
                    onSelectA: { viewModel.select(a) },
                    onSelectB: { viewModel.select(b) }
                )
            } else {
                ProgressView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 40)
    }
}

#Preview {
    TournamentView(title: "타이틀 확인중", id: UUID())
}
