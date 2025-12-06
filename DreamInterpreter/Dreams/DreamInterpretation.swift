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
}
