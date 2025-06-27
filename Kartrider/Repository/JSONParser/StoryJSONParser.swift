//
//  StoryJSONParser.swift
//  Kartrider
//
//  Created by J on 5/29/25.
//

import Foundation
import SwiftData

// TODO: Generic + Protocol로 리팩토링
// TODO: small Camel Case로 바꾸세요!
// TODO: 객체로 바꾸세요!
// TODO: 1. StoryJSONParser, TournamentJSONParser를 합친다. -> JSONParser로 통합
// TODO: 2. StoryJSON, TournamentJSON -> 프로토콜로 통합
// TODO: 3. StoryJSON, TournamentJSON 따라 로직을 분기한다! (분기하는 로직도 extension으로 빼면 좋을 것 같음!)
enum StoryJSONParser {
    static func loadJSON(named fileName: String) -> Data? {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            print("[ERROR] JSON 파일을 찾을 수 없습니다 - \(fileName)")
            return nil
        }
        return try? Data(contentsOf: url)
    }
    
    
    static func parseAndInsertStories(from jsonData: Data, context: ModelContext) throws {
        let decoder = JSONDecoder()
        let storyList = try decoder.decode([StoryJSON].self, from: jsonData)
        
        for storyJSON in storyList {
            // Meta
            let meta = ContentMeta(
                title: storyJSON.meta.title,
                summary: storyJSON.meta.summary,
                type: ContentType(rawValue: storyJSON.meta.type) ?? .story,
                hashtags: storyJSON.meta.hashtags,
                thumbnailName: storyJSON.meta.thumbnailName
            )
            context.insert(meta)
            
            // Story
            let story = Story(startNodeId: storyJSON.story.startNodeId, meta: meta)
            context.insert(story)
            
            print("[DEBUG] Story 저장됨: startNode = \(story.startNodeId)")
            
            // Nodes
            for nodeData in storyJSON.story.nodes {
                let node = StoryNode(
                    id: nodeData.id,
                    text: nodeData.text,
                    type: nodeData.type,
                    nextId: nodeData.nextId,
                    endingIndex: nodeData.endingIndex,
                    title: nodeData.title,
                    story: story
                )
                
                context.insert(node)
                
//                print(" 현재 노드: \(nodeData.id) / type: \(nodeData.type)")
                
                if let choiceA = nodeData.choiceA {
                    let a = StoryChoice(text: choiceA.text, toId: choiceA.toId)
                    context.insert(a)
                    node.choiceA = a
                }
                if let choiceB = nodeData.choiceB {
                    let b = StoryChoice(text: choiceB.text, toId: choiceB.toId)
                    context.insert(b)
                    node.choiceB = b
                }
            }
            
            // Ending Conditions
            for endingConditionsData in storyJSON.story.endingConditions {
                let endingCondition = EndingCondition(
                    pathString: endingConditionsData.path.map { $0.rawValue }.joined(separator: "-"),
                    toId: endingConditionsData.toId
                )
                endingCondition.story = story
                context.insert(endingCondition)
            }
        }
        try context.save()
        
        // Debug 출력
        print("[DEBUG] 저장된 Story 수: \(try context.fetch(FetchDescriptor<Story>()).count)")
        print("[DEBUG] 저장된 StoryNode 수: \(try context.fetch(FetchDescriptor<StoryNode>()).count)")
        print("[DEBUG] 저장된 ContentMeta 수: \(try context.fetch(FetchDescriptor<ContentMeta>()).count)")
    }
}
