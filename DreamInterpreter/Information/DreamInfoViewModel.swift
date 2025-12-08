//
//  DreamInfoViewModel.swift
//  DreamInterpreter
//
//  Created by John Martino on 12/7/25.
//

import SwiftUI
internal import Combine

@MainActor
class DreamInfoViewModel: ObservableObject {
    @Published var dreamInfo: DreamInfo?
    @Published var isLoading = false
    
    init() {
        loadDreamInfo()
    }
    
    private func loadDreamInfo() {
        guard let url = Bundle.main.url(forResource: "Archetypes", withExtension: "json") else {
            print("[DreamInfoViewModel] Archetypes.json not found in bundle")
            return
        }
        do {
            isLoading = true
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode(DreamInfo.self, from: data)
            self.dreamInfo = decoded
            isLoading = false
        } catch {
            print("[DreamInfoViewModel] Failed to load/decode Archetypes.json: \(error)")
            isLoading = false
        }
    }
}
