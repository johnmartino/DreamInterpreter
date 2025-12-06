//
//  ContentView.swift
//  DreamInterpreter
//
//  Created by John Martino on 12/4/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var service = AIService()
    @StateObject private var viewModel = ContentViewModel()
    
    var body: some View {
        NavigationStack {
            contentView
                .navigationTitle("Dream Interpreter")
                .toolbarTitleDisplayMode(.inlineLarge)
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            viewModel.dream = nil
                        } label: {
                            Image(systemName: "eraser")
                        }
                    }
                }
        }
    }
    
    @ViewBuilder private var contentView: some View {
        let (isAvailable, reason) = service.isAvailable()
        if !isAvailable {
            ContentUnavailableView("Language Model", systemImage: "apple.intelligence", description: Text(reason ?? "Unexpected error occurred."))
        } else {
            interpretationView
                .safeAreaInset(edge: .bottom) {
                    InputView { text in send(text) }
                        .disabled(viewModel.isQuerying)
                        .padding(8)
                }
        }
    }
    
    @ViewBuilder private var interpretationView: some View {
        if viewModel.isQuerying {
            ProgressView("Interpreting your dream...")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let message = viewModel.errorMessage {
            ContentUnavailableView(message, systemImage: "apple.intelligence")
                .foregroundStyle(.secondary)
        } else if let dream = viewModel.dream {
            detailsView(dream: dream)
        } else {
            ContentUnavailableView("Describe your dream", systemImage: "person.icloud")
                .foregroundStyle(.secondary)
        }
    }
    
    @ViewBuilder private func detailsView(dream: Dream) -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                Text(dream.title).font(.headline)
                
                VStack(alignment: .leading) {
                    Text("Summary").font(.caption).bold().foregroundStyle(.secondary)
                    Text(dream.summary)
                }
                
                ForEach(dream.archetypes) { archetype in
                    VStack(alignment: .leading) {
                        Text(archetype.name).font(.caption).bold().foregroundStyle(.secondary)
                        Text(archetype.dreamCounterpart)
                    }
                }
                
                VStack(alignment: .leading) {
                    Text("Interpretation").font(.caption).bold().foregroundStyle(.secondary)
                    Text(dream.description)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
        }
    }
    
    private func send(_ text: String) {
        Task {
            await viewModel.interpret(dreamText: text)
        }
    }
}

#Preview {
    ContentView()
}
