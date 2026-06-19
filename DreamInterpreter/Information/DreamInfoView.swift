//
//  DreamInfoView.swift
//  DreamInterpreter
//
//  Created by John Martino on 12/7/25.
//

import SwiftUI

struct DreamInfoView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = DreamInfoViewModel()
    
    var body: some View {
        if viewModel.isLoading {
            ProgressView("Loading dream info...")
        } else if let info = viewModel.dreamInfo {
            archetypeInfoView(for: info)
        } else {
            ContentUnavailableView("Info not available", systemImage: "xmark")
        }
    }
    
    @ViewBuilder private func archetypeInfoView(for info: DreamInfo) -> some View {
        NavigationStack {
            List {
                ForEach(info.categories) { category in
                    Section(category.name) {
                        ForEach(category.archetypes) { archetype in
                            VStack(alignment: .leading) {
                                Text(archetype.name).font(.headline)
                                Text(archetype.description)
                            }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Archetypes")
            .toolbarTitleDisplayMode(.inlineLarge)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
    }
}

#Preview {
    DreamInfoView()
}
