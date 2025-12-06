//
//  DreamView.swift
//  DreamInterpreter
//
//  Created by John Martino on 12/6/25.
//

import SwiftUI

struct DreamView: View {
    let dream: Dream
    
    var body: some View {
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
                Text(dream.interpretation)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
    }
}

#Preview(traits: .mockData) {
    DreamView(dream: MockData.sample.dream)
}
