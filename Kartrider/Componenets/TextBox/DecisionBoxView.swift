//
//  DecisionBoxView.swift
//  Kartrider
//
//  Created by 박난 on 6/2/25.
//

import SwiftUI

struct DecisionBoxView: View {
    let text: String
    let storyChoiceOption: StoryChoiceOption
    let toId: String
    
    var body: some View {
        // TODO: 버튼일 때랑 버튼 아닐 때랑 나눠서 만들기
        HStack {
            Text("\(storyChoiceOption)")
                .font(.title)
                .bold()
            Text(text)
                .font(.body)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(.primaryOrange)
                .fill(.backgroundOrangeLight)
        )
        .padding(.horizontal, 16)
    }
}
