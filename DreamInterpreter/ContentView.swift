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
        }
    }
    
    @ViewBuilder private var contentView: some View {
        let (isAvailable, reason) = service.isAvailable()
        if !isAvailable {
            ContentUnavailableView("Language Model", systemImage: "apple.intelligence", description: Text(reason ?? "Unexpected error occurred."))
        } else {
            interpretationView
                .safeAreaInset(edge: .bottom) {
                    InputView(borderColor: .gray) { text in send(text) }
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
        } else {
            detailsView
        }
    }
    
    @ViewBuilder private var detailsView: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                if let title = viewModel.dream?.title {
                    Text(title).font(.headline)
                }
                
                if let summary = viewModel.dream?.summary {
                    VStack(alignment: .leading) {
                        Text("Summary").font(.caption).bold().foregroundStyle(.secondary)
                        Text(summary)
                    }
                }
                
                if let archetypes = viewModel.dream?.archetypes {
                    ForEach(archetypes) { archetype in
                        VStack(alignment: .leading) {
                            Text(archetype.name).font(.caption).bold().foregroundStyle(.secondary)
                            Text(archetype.dreamCounterpart)
                        }
                    }
                }
                
                if let interpretation = viewModel.dream?.description {
                    VStack(alignment: .leading) {
                        Text("Interpretation").font(.caption).bold().foregroundStyle(.secondary)
                        Text(interpretation)
                    }
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
