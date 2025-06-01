//
//  TextBoxView.swift
//  Kartrider
//
//  Created by 박난 on 6/1/25.
//

import SwiftUI

struct TextBoxView: View {
    let text: String
    
    var body: some View {
        Text(text)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.red)
            )
            .foregroundColor(.textPrimary)
            .font(.title)
            .padding(16)
    }
}
