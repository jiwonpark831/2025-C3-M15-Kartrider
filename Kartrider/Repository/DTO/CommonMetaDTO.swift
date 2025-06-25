//
//  CommonMetaDTO.swift
//  Kartrider
//
//  Created by J on 5/29/25.
//

import Foundation

// MARK: - 파일 이름 바꾸세요~
struct MetaData: Decodable {
    let title: String
    let summary: String
    let type: String
    let hashtags: [String]
    let thumbnailName: String
}

