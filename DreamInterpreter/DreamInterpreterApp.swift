//
//  DreamInterpreterApp.swift
//  DreamInterpreter
//
//  Created by John Martino on 12/4/25.
//

import SwiftUI
import SwiftData

@main
struct DreamInterpreterApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [DreamInterpretation.self])
    }
}
