//
//  TextFormatter.swift
//  Kartrider
//
//  Created by J on 6/1/25.
//

import Foundation

// TODO: Utility/Extensions/String+.swift 등으로 수정하기
extension String {
    func insertLineBreak(every n: Int) -> String {
        var result = ""
        var current = ""
        for word in self.split(separator: " "){
            if current.count + word.count + 1 > n {
                result += current + "\n"
                current = String(word)
            } else {
                current += current.isEmpty ? String(word) : " " + word
            }
        }
        result += current
        return result
    }
}
