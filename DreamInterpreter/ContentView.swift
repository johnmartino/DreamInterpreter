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
    
    @State private var showDreamHistory = false
    @State private var showInfo = false
    @State private var saved = false
    
    var body: some View {
        NavigationStack {
            contentView
                .navigationTitle("Somnify")
                .toolbarTitleDisplayMode(.inlineLarge)
                .toolbar {
                    ToolbarItemGroup(placement: .primaryAction) {
                        Button {
                            showInfo.toggle()
                        } label: {
                            Image(systemName: "info")
                        }
                        
                        Button {
                            showDreamHistory.toggle()
                        } label: {
                            Image(systemName: "list.bullet")
                        }
                    }
                }
                .fullScreenCover(isPresented: $showDreamHistory) {
                    DreamListView() {
                        let interpretation = fetchInterpretation(title: viewModel.dream?.title, dreamDescription: viewModel.latestDreamText)
                        saved = interpretation != nil
                    }
                }
                .fullScreenCover(isPresented: $showInfo) {
                    DreamInfoView()
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
            MatrixRainView()
                .ignoresSafeArea()
        }
    }
    
    @ViewBuilder private func detailsView(dream: Dream) -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                DreamView(dream: dream)
                actionButtons
            }
        }
    }
    
    @ViewBuilder private var actionButtons: some View {
        if let dream = viewModel.dream {
            let interpretation = DreamInterpretation(description: viewModel.latestDreamText, dream: dream)
            
            HStack {
                Button {
                    viewModel.dream = nil
                } label: {
                    Label("Clear", systemImage: "trash")
                        .font(.footnote)
                        .foregroundStyle(Color(.systemBackground))
                }
                .tint(.primary)
                .buttonStyle(.glassProminent)
                
                Button {
                    context.insert(interpretation)
                    do {
                        try context.save()
                        saved = true
                    } catch {
                        print("Failed to save dream: \(error)")
                    }
                } label: {
                    Label("Save", systemImage: "square.and.arrow.down")
                        .font(.footnote)
                        .foregroundStyle(Color(.systemBackground))
                }
                .tint(.primary)
                .buttonStyle(.glassProminent)
                .disabled(saved)
                
                Spacer()
                
                ShareLink(item: interpretation.shareText) {
                    Label("Share", systemImage: "square.and.arrow.up")
                        .font(.footnote)
                        .foregroundStyle(Color(.systemBackground))
                }
                .tint(.primary)
                .buttonStyle(.glassProminent)
            }
            .padding(.horizontal)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    private func send(_ text: String) {
        Task {
            await viewModel.interpret(dreamText: text)
        }
    }
    
    private func fetchInterpretation(title: String?, dreamDescription: String) -> DreamInterpretation? {
        guard let title else { return nil }
        var descriptor = FetchDescriptor<DreamInterpretation>(
            predicate: #Predicate { $0.dream.title == title && $0.dreamDescription == dreamDescription },
            sortBy: []
        )
        descriptor.fetchLimit = 1
        do {
            let results = try context.fetch(descriptor)
            return results.first
        } catch {
            print("Failed to fetch DreamInterpretation by title: \(error)")
            return nil
        }
    }
}

#Preview {
    ContentView()
}
