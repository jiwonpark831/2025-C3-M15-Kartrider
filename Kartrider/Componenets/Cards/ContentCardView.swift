//
//  StoryCardView.swift
//  Kartrider
//
//  Created by J on 5/31/25.
//

import SwiftUI

struct ContentCardView: View {
    let content: ContentMeta
    var showsTags: Bool = true
    
    private var thumbnailImage: Image {
        guard let name = content.thumbnailName, UIImage(named: name) != nil else {
            return Image("default_thumbnail")
        }
        return Image(name)
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            thumbnailImage
                .resizable()
                .scaledToFill()
                .frame(width: 300, height: 480)
                .cornerRadius(16)
                .overlay (
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.divider, lineWidth: 1)
                )
            
            if showsTags {
                HStack(spacing: 8) {
                    ForEach(content.hashtags, id:\.self ) { tag in
                        TagBadgeView(text: tag, style: .primary)
                    }
                }
                .padding(16)
            }
        }
        .padding()
    }
}

#Preview {
    ContentCardView(content: ContentMeta(title: "눈 떠보니 내가 T1 페이커?!", summary: "오늘이 MSI 결승인데, 아이언인 내가 페이커 몸에 들어와버림", type: .story, hashtags: ["페이커", "빙의", "큰일남"], thumbnailName: ""))
    .padding()
}
