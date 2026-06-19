//
//  FoundationManager.swift
//  DreamInterpreter
//
//  Created by John Martino on 12/4/25.
//

import Foundation
import FoundationModels

@Observable
final class FoundationManager {
    var notAvailableReason = "Checking model availability..."
    var isModelAvailable: Bool {
        notAvailableReason.isEmpty
    }
    
    init() {
        checkIsAvailable()
    }
    
    @discardableResult
    func checkIsAvailable() -> Bool {
        switch SystemLanguageModel.default.availability {
            case .available:
                notAvailableReason = ""
            case .unavailable(.deviceNotEligible):
                notAvailableReason = "Upgrade to use Apple Intelligence"
            case .unavailable(.appleIntelligenceNotEnabled):
                notAvailableReason = "Enable Apple Intelligence in System Settings."
            case .unavailable(.modelNotReady):
                notAvailableReason = "Model not ready. Downloding or temporarily unavailable. Please wait, ensure sufficient battery and Wi-Fi."
            case.unavailable(let unknownReason):
                notAvailableReason = "Model unavailable: \(String(describing: unknownReason))"
        }
        return isModelAvailable
    }
}
