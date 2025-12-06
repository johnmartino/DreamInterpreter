//
//  ContentView.swift
//  DreamInterpreter
//
//  Created by John Martino on 12/4/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) var context
    @StateObject private var service = AIService()
    @StateObject private var viewModel = ContentViewModel()
    @Query private var interpretations: [DreamInterpretation]
    
    @State private var showDreamHistory = false
    
    var body: some View {
        NavigationStack {
            contentView
                .navigationTitle("Reve AI")
                .toolbarTitleDisplayMode(.inlineLarge)
                .toolbar {
                    ToolbarItemGroup(placement: .primaryAction) {
                        if let dream = viewModel.dream {
                            Button {
                                viewModel.dream = nil
                            } label: {
                                Image(systemName: "eraser")
                            }
                            
                            Button {
                                let interpretation = DreamInterpretation(description: viewModel.latestDreamText, dream: dream)
                                context.insert(interpretation)
                                try? context.save()
                            } label: {
                                Image(systemName: "square.and.arrow.down")
                            }
                        }
                        
                        if interpretations.count > 0 {
                            Button {
                                showDreamHistory.toggle()
                            } label: {
                                Image(systemName: "list.bullet")
                            }
                        }
                    }
                }
                .fullScreenCover(isPresented: $showDreamHistory) {
                    DreamListView()
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
            DreamView(dream: dream)
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
