//
//  LaunchView.swift
//  Kartrider
//
//  Created by J on 6/5/25.
//

import SwiftUI

struct LaunchView: View {
    var body: some View {
        ZStack {
            Color.primaryOrange
                .edgesIgnoringSafeArea(.all)

            GIFView(gifName: "launch")
//                .aspectRatio(contentMode: .fit)
//                .frame(maxWidth: UIScreen.main.bounds.width)
//                .clipped()
        }
        
    }
}

#Preview {
    LaunchView()
}
