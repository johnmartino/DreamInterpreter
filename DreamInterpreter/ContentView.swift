//
//  ContentView.swift
//  DreamInterpreter
//
//  Created by John Martino on 12/4/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @StateObject private var service = AIService()
    @StateObject private var viewModel = ContentViewModel()
    
    @State private var showDreamHistory = false
    @State private var showInfo = false
    @State private var saved = false
    @State private var saveError: String?
    
    @Namespace private var namespace
    
    var body: some View {
        NavigationStack {
            contentView
                .navigationTitle("Dream Self")
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
                .sheet(item: $viewModel.dream) { dream in
                    NavigationStack {
                        detailsView(dream: dream)
                    }
                }
                .alert("Save Failed", isPresented: Binding(
                    get: { saveError != nil },
                    set: { if !$0 { saveError = nil } }
                )) {
                    Button("OK", role: .cancel) { saveError = nil }
                } message: {
                    Text(saveError ?? "The dream could not be saved.")
                }
        }
    }
    
    @ViewBuilder private var contentView: some View {
        let (isAvailable, reason) = service.isAvailable()
        if !isAvailable {
            ContentUnavailableView("Language Model", systemImage: "apple.intelligence", description: Text(reason ?? "Unexpected error occurred."))
        } else {
            interpretationView
        }
    }
    
    @ViewBuilder private var interpretationView: some View {
        if let message = viewModel.errorMessage {
            ContentUnavailableView(message, systemImage: "apple.intelligence")
                .foregroundStyle(.secondary)
        } else {
            ZStack {
                MatrixRainView()
                    .ignoresSafeArea()

                if #available(iOS 27.1, *), horizontalSizeClass == .regular {
                    ArrangementView {
                        CrystalBallView(diameter: 150, coolColor: .teal, hotColor: colorScheme == .dark ? .black : .white)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    } secondary: {
                        interpretingDreamTextView
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .safeAreaInset(edge: .bottom) {
                                dreamInputView
                            }
                    }
                } else {
                    VStack(spacing: 32) {
                        CrystalBallView(diameter: 150, coolColor: .teal, hotColor: colorScheme == .dark ? .black : .white)
                        interpretingDreamTextView
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .safeAreaInset(edge: .bottom) {
                        dreamInputView
                    }
                }
            }
        }
    }
    
    private var dreamInputView: some View {
        InputView { text in send(text) }
            .disabled(viewModel.isQuerying)
            .padding(8)
    }

    @ViewBuilder private var interpretingDreamTextView: some View {
        ZStack {
            Color.clear
                .frame(width: 0, height: 0)

            if viewModel.isQuerying {
                Text("Interpreting your dream")
                    .foregroundStyle(.teal)
                    .padding()
                    .glassEffect(.clear.tint(.teal.opacity(0.15)), in: .capsule)
                    .glassEffectID("query", in: namespace)
                    .glassEffectTransition(.matchedGeometry)
            }
        }
    }

    @ViewBuilder private func detailsView(dream: Dream) -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            DreamView(dream: dream.record)
        }
        .toolbar {
            actionButtons
        }
    }
    
    @ToolbarContentBuilder private var actionButtons: some ToolbarContent {
        if let dream = viewModel.dream {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    viewModel.dream = nil
                } label: {
                    Label("Clear", systemImage: "xmark")
                }
            }
            
            ToolbarItemGroup(placement: .primaryAction) {
                Group {
                    Button {
                        save(dream)
                        viewModel.dream = nil
                    } label: {
                        Label("Save", systemImage: "checkmark")
                    }
                    .disabled(saved)
                    
                    ShareLink(item: dream.shareText(dreamDescription: viewModel.latestDreamText)) {
                        Label("Share", systemImage: "square.and.arrow.up")
                            .font(.footnote)
                    }
                }
            }
        }
    }
    
    private func send(_ text: String) {
        saved = false
        saveError = nil
        Task {
            await viewModel.interpret(dreamText: text)
        }
    }

    private func save(_ dream: Dream) {
        do {
            let interpretation = DreamInterpretation(
                description: viewModel.latestDreamText,
                dream: dream.record
            )
            context.insert(interpretation)
            try context.save()
            saved = true
        } catch {
            context.rollback()
            saveError = error.localizedDescription
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
