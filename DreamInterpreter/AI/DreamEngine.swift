//
//  DreamEngine.swift
//  DreamInterpreter
//
//  Created by John Martino on 12/4/25.
//

import Foundation
import FoundationModels

class DreamEngine {
    func interpret(dream: String) async throws -> Dream {
        let session = LanguageModelSession(instructions: Instructions {
            "You are a dream interpreter."
            "You will analyze a dream description and provide an interpretation based on the works of Carl Jung."
            "Specifically, draw from the following works: Psychological Types, The Archetypes and the Collective Unconsioous, and Man and His Symbols."
            "Your tone should be warm and amiable."
        })
        let response = try await session.respond(to: dream, generating: Dream.self)
        return response.content
    }
}

@Generable
struct Archetype: ConvertibleFromGeneratedContent, Identifiable, Codable {
    var id: String { name }
    
    @Guide(description: "The name of the archetype.")
    let name: String

    @Guide(description: "The dream counterpart or symbol for this archetype.")
    let dreamCounterpart: String
    
    var description: String {
        "\(name): \(dreamCounterpart)"
    }
}

@Generable
struct Dream: ConvertibleFromGeneratedContent, Codable {
    @Guide(description: "A title for the dream.")
    let title: String
    
    @Guide(description: "A list of archetype symbols and their dream counterparts.")
    let archetypes: [Archetype]
    
    @Guide(description: "A very brief summary of the dream meaning.")
    let summary: String
    
    @Guide(description: "A detailed interpretation of the dream, drawing from works like The Archetypes and the Collective Unconscious. Do not define the archetypes here. Refrain from stating Carl Jung's name.")
    let interpretation: String
}
