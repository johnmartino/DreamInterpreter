//
//  AIService.swift
//  DreamInterpreter
//
//  Created by John Martino on 12/5/25.
//

import SwiftUI
import Combine
import FoundationModels

@MainActor
final class AIService: ObservableObject {
    @Published var response = ""
    @Published var specialMessage: String?
    
    private var model = SystemLanguageModel.default
    private let options = GenerationOptions(sampling: .greedy, temperature: 2.0)
    private let session: LanguageModelSession
    
    init() {
        session = LanguageModelSession(instructions: "You are a my intelligent personal assistant.")
        specialMessage = "A new session has started"
    }
    
    func isAvailable() -> (Bool, String?) {
        switch model.availability {
            case .available:
                return (true, nil)
            case .unavailable(.deviceNotEligible):
                return(false, "This device isn't eligible for Apple Intelligence.")
            case .unavailable(.appleIntelligenceNotEnabled):
                return(false, "Apple Intelligence isn't enabled on your device.")
            case .unavailable(.modelNotReady):
                return(false, "The Apple Intelligence model isn't ready yet.")
            case .unavailable(let other):
                return(false, "An unknown error occurred: \(other)")
        }
    }
    
    var busy: Bool {
        session.isResponding
    }
    
    func respond(to text: String) async throws {
        let stream = session.streamResponse(to: text)
        for try await partialResponse in stream {
            self.response = partialResponse.content
        }
    }
}
