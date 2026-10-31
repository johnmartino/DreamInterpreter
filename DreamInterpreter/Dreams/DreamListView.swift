//
//  DreamListView.swift
//  DreamInterpreter
//
//  Created by John Martino on 12/6/25.
//

import SwiftUI
import SwiftData

struct DreamListView: View {
    @Environment(\.modelContext) var context
    @Environment(\.dismiss) var dismiss
    @State private var selectedDream: DreamInterpretation?
    
    @Query(sort: [SortDescriptor(\DreamInterpretation.timestamp, order: .reverse)]) private var dreams: [DreamInterpretation]
    
    let didDismiss: () -> Void
    
    var body: some View {
        NavigationSplitView {
            Group {
                if dreams.isEmpty {
                    ContentUnavailableView("No saved dreams", systemImage: "person.icloud")
                        .foregroundStyle(.secondary)
                } else {
                    dreamsView
                }
            }
            .navigationTitle("Dreams")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                        didDismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
        } detail: {
            if let selectedDream {
                dreamDetailsView(for: selectedDream)
            } else {
                Text("Select a dream to view its interpretation.")
                    .font(.headline)
                    .padding(.horizontal)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    private var dreamsView: some View {
        List(selection: $selectedDream) {
            ForEach(dreams) { dream in
                NavigationLink(value: dream) {
                    VStack(alignment: .leading) {
                        Text(dream.timestamp.dateStamp)
                            .font(.caption).bold()
                            .foregroundStyle(.secondary)
                        Text(dream.dream.title)
                            .font(.headline)
                        Text(dream.dream.summary)
                    }
                    .tint(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .listRowSeparator(.hidden)
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        withAnimation {
                            if selectedDream == dream {
                                selectedDream = nil
                            }
                            context.delete(dream)
                            try? context.save()
                        }
                    } label: {
                        Image(systemName: "trash")
                    }
                }
            }
        }
        .listStyle(.plain)
    }
    
    private func dreamDetailsView(for interpretation: DreamInterpretation) -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack {
                DreamView(dream: interpretation.dream)
                
                VStack(alignment: .leading) {
                    Text("Dream Description")
                        .font(.caption).bold().foregroundStyle(.secondary)
                    Text(interpretation.dreamDescription)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding([.horizontal, .top])
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    ShareLink(item: interpretation.shareText) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
        }
    }
}

#Preview(traits: .mockData) {
    DreamListView() {
        
    }
}
