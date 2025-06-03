//
//  TournamentMatchView.swift
//  Kartrider
//
//  Created by J on 6/2/25.
//

import SwiftUI

struct TournamentMatchView: View {
    let roundDescription: String
    let a: String
    let b: String
    let onSelectA: () -> Void
    let onSelectB: () -> Void
    
    var body: some View {
        VStack(spacing: 18) {
            DescriptionBoxView(text: roundDescription)
            
            VStack(spacing: 16) {
                DecisionBoxView(text: a, storyChoiceOption: StoryChoiceOption.a, action: onSelectA)
                DecisionBoxView(text: b, storyChoiceOption: StoryChoiceOption.b, action: onSelectB)
            }
            
            Spacer()
            
            Text("다음 컨텐츠가 10초 후에 재생됩니다.")
                .font(.callout)
                .foregroundColor(Color.textSecondary)
            
            
        }
    }
}

#Preview {
    TournamentMatchView(roundDescription: "결승\n1번째 경기 중 1번째", a: "젤리", b: "펩시 제로 슈거 라임향", onSelectA: {}, onSelectB: {})
}
