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
                .ignoresSafeArea()
            Image("logo_white")
                .padding(.bottom, 200)
        }
        
    }
}

#Preview {
    LaunchView()
}
