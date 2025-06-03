//
//  TournamentDTO.swift
//  Kartrider
//
//  Created by J on 5/29/25.
//

import Foundation

//[
//  {
//    "meta": {
//      "title": "최고의 간식 월드컵",
//      "type": "tournament",
//      "hashtags": ["간식", "맛있는", "간식최강자"],
//      "thumbnailName": "snack_thumb"
//    },
//    "candidates": [
//      { "name": "붕어빵" },
//      { "name": "떡볶이" },
//      { "name": "치킨" },
//      { "name": "소떡소떡" }
//    ]
//  },
//  {
//    "meta": {
//      "title": "여름 필수템 월드컵",
//      "type": "tournament",
//      "hashtags": ["여름", "필수템", "생존템"],
//      "thumbnailName": "summer_thumb"
//    },
//    "candidates": [
//      { "name": "선풍기" },
//      { "name": "아이스커피" },
//      { "name": "모기약" },
//      { "name": "물놀이 튜브" }
//    ]
//  }
//]


struct TournamentJSON: Decodable {
    let meta: MetaData
    let candidates: [CandidateData]
}

struct CandidateData: Decodable {
    let name: String
}

