//
//  ContentViewModel.swift
//  DreamInterpreter
//
//  Created by John Martino on 12/5/25.
//

import SwiftUI
internal import Combine

class ContentViewModel: ObservableObject {
    let engine = DreamEngine()
    
    @Published var dream: Dream?
    @Published var errorMessage: String?
    @Published var isQuerying = false
    @Published var latestDreamText = ""
    
    @MainActor func interpret(dreamText: String) async {
        latestDreamText = dreamText
        do {
            isQuerying = true
            dream = try await engine.interpret(dream: dreamText)
            isQuerying = false
        } catch {
            errorMessage = error.localizedDescription
            isQuerying = false
        }
    }
}
