//
//  DreamInterpretation.swift
//  DreamInterpreter
//
//  Created by John Martino on 12/6/25.
//

import Foundation
import SwiftData

@Model
class ArchetypeRecord {
    var name: String
    var dreamCounterpart: String
    
    init(name: String, dreamCounterpart: String) {
        self.name = name
        self.dreamCounterpart = dreamCounterpart
    }
    
    var description: String {
        "\(name): \(dreamCounterpart)"
    }
}

@Model
class DreamRecord {
    var title: String
    @Relationship(deleteRule: .cascade)
    var archetypes: [ArchetypeRecord]
    var summary: String
    var interpretation: String
    
    init(title: String, archetypes: [ArchetypeRecord], summary: String, interpretation: String) {
        self.title = title
        self.archetypes = archetypes
        self.summary = summary
        self.interpretation = interpretation
    }
}

@Model
class DreamInterpretation {
    var timestamp: Date
    var dreamDescription: String
    var dream: DreamRecord
    
    init(description: String, dream: DreamRecord) {
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
