//
//  DreamPlayground.swift
//  DreamInterpreter
//
//  Created by John Martino on 12/4/25.
//

import Foundation
import Playgrounds

#Playground {
    let engine = DreamEngine()
    let myDream = """
        I was trying to get home after a late night concert in New York City but I found myself running into people and unable to find my car. First I ran into my cousin, who lives in Vancouver. We were talking for a bit and as I was about to leave his brother shows up. He lives in South Carolina. We joke around then I leave. I was walking down a street that looked very familiar but nowhere near my car. I wondered how I got that far.
        """
    let dream = try await engine.interpret(dream: myDream)
    
    print("Archetypes:")
    for archetype in dream.archetypes {
        print(archetype.name + ": " + archetype.dreamCounterpart)
    }
    print("Summary: " + dream.summary)
    print(dream.description)
}
