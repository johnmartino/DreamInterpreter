//
//  ContentViewModel.swift
//  DreamInterpreter
//
//  Created by John Martino on 12/5/25.
//

import SwiftUI
import Combine

class ContentViewModel: ObservableObject {
    let engine = DreamEngine()
    
    @Published var dream: Dream?
    @Published var errorMessage: String?
    @Published var isQuerying = false
    
    @MainActor func interpret(dreamText: String) async {
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
