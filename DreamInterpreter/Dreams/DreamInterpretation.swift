//
//  DreamInterpretation.swift
//  DreamInterpreter
//
//  Created by John Martino on 12/6/25.
//

import Foundation
import SwiftData

@Model
class DreamInterpretation {
    private(set) var timestamp: Date
    private(set) var dreamDescription: String
    private(set) var dream: Dream
    
    init(description: String, dream: Dream) {
        self.timestamp = Date.now
        self.dreamDescription = description
        self.dream = dream
    }
    
    var shareText: String {
        let archetypeList: String = {
            let items = dream.archetypes.map { "- \($0.description)" }
            if items.isEmpty {
                return "- None"
            } else {
                return items.joined(separator: "\n")
            }
        }()
        
        return """
        \(dream.title)
        
        Summary:
        \(dream.summary)
        
        Archetypes:
        \(archetypeList)
        
        Interpretation:
        \(dream.interpretation)
        
        Original Description:
        \(dreamDescription)
        """
    }
}
