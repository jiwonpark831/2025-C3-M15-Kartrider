//
//  ContentCarouselView.swift
//  Kartrider
//
//  Created by J on 5/31/25.
//

import SwiftUI

struct ContentCarouselView: View {
    let contents: [ContentMeta]
    var onTap: (ContentMeta) -> Void
    
    @GestureState private var translation: CGFloat = 0
    @State private var currentIndex: Int = 0
    
    var body: some View {
        GeometryReader { geometry in
            let cardWidth = geometry.size.width * 0.7
            let spacing: CGFloat = 16
            let totalSpacing = spacing + cardWidth
            let horizontalPadding = (geometry.size.width - cardWidth) / 2
            
            HStack(spacing: spacing) {
                ForEach(contents.indices, id: \.self) { index in
                    ContentCardView(content: contents[index])
                        .frame(width: cardWidth)
                        .scaleEffect(currentIndex == index ? 1.0 : 0.9)
                        .animation(.easeInOut(duration: 0.25), value: currentIndex)
                        .onTapGesture {
                            onTap(contents[index])
                        }
                }
            }
            .padding(.horizontal, horizontalPadding)
            .offset(x: -CGFloat(currentIndex) * totalSpacing + translation)
            .gesture(
                DragGesture()
                    .updating($translation) { value, state, _ in
                        state = value.translation.width
                    }
                    .onEnded { value in
                        let offset = value.translation.width / totalSpacing
                        let newIndex = (CGFloat(currentIndex) - offset).rounded()
                        currentIndex = max(0, min(contents.count - 1, Int(newIndex)))
                    }
            )
        }
        .frame(height: 500)
        // Page Indicator
        PageIndicatorView(
            totalCount: contents.count,
            currentIndex: currentIndex
        )
        
        .onAppear {
            currentIndex = contents.count / 2
        }
        .onChange(of: contents) { newValue in
            if !newValue.isEmpty {
                currentIndex = newValue.count / 2
            }
        }
    }
}

#Preview {
    let dummyContents: [ContentMeta] = [
        ContentMeta(
            title: "눈 떠보니 내가 T1 페이커?!",
            summary: "오늘이 MSI 결승인데, 아이언인 내가 페이커 몸에 들어와버림",
            type: .story,
            hashtags: ["페이커", "빙의", "큰일남"],
            thumbnailName: nil
        ),
        ContentMeta(
            title: "마법학교 입학 통지서",
            summary: "갑자기 부엉이가 날아와 입학하래",
            type: .story,
            hashtags: ["마법", "학원물"],
            thumbnailName: nil
        ),
        ContentMeta(
            title: "아쉬워 벌써 12시",
            summary: "아쉬워 벌써 12시네",
            type: .story,
            hashtags: ["절대 집에 가", "청하", "메아리"],
            thumbnailName: nil
        )
    ]
    
    return ContentCarouselView(contents: dummyContents) { selected in
        print("선택된 콘텐츠: \(selected.title)")
    }
}
