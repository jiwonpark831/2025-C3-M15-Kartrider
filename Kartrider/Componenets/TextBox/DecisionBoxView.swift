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
        HStack {
            Text("\(storyChoiceOption)")
                .font(.largeTitle)
                .bold()
            Text(text)
                .font(.title)
        }
        .padding()
        .frame(width: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(.primaryOrange)
                .fill(.backgroundOrangeLight)
        )
        
    }
}
