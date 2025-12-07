//
//  MockData.swift
//  DreamInterpreter
//
//  Created by John Martino on 12/6/25.
//


import SwiftUI
import SwiftData

struct MockData: PreviewModifier {
    func body(content: Content, context: ModelContainer) -> some View {
        content
            .modelContainer(context)
    }
    
    static func makeSharedContext() async throws -> ModelContainer {
        do {
            let container = try ModelContainer(for: DreamInterpretation.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
            
            container.mainContext.insert(Self.sample)
            container.mainContext.insert(Self.sample)
            container.mainContext.insert(Self.sample)
            
            return container
        } catch {
            fatalError()
        }
    }
    
    static var sample: DreamInterpretation {
        let dream = Dream(
            title: "The Third Eye",
            archetypes: [Archetype(name: "The Shadow", dreamCounterpart: "Lorem ipsum dolor sit amet consectetur adipiscing elit."), Archetype(name: "The Self", dreamCounterpart: "Lorem ipsum dolor sit amet consectetur adipiscing elit.")],
            summary: "Lorem ipsum dolor sit amet consectetur adipiscing elit. Dolor sit amet consectetur adipiscing elit quisque faucibus.",
            interpretation: "Lorem ipsum dolor sit amet consectetur adipiscing elit. Ex sapien vitae pellentesque sem placerat in id. Pretium tellus duis convallis tempus leo eu aenean. Urna tempor pulvinar vivamus fringilla lacus nec metus. Iaculis massa nisl malesuada lacinia integer nunc posuere. Semper vel class aptent taciti sociosqu ad litora. Conubia nostra inceptos himenaeos orci varius natoque penatibus. Dis parturient montes nascetur ridiculus mus donec rhoncus. Nulla molestie mattis scelerisque maximus eget fermentum odio. Purus est efficitur laoreet mauris pharetra vestibulum fusce."
        )
        return DreamInterpretation(description: "Lorem ipsum dolor sit amet consectetur adipiscing elit. Consectetur adipiscing elit quisque faucibus ex sapien vitae. Ex sapien vitae pellentesque sem placerat in id. Placerat in id cursus mi pretium tellus duis. Pretium tellus duis convallis tempus leo eu aenean.", dream: dream)
    }
}

extension PreviewTrait where T == Preview.ViewTraits {
    static var mockData: Self = .modifier(MockData())
}


//// Search the model container for a record by title
//private func fetchInterpretation(byTitle title: String) -> DreamInterpretation? {
//    var descriptor = FetchDescriptor<DreamInterpretation>(
//        predicate: #Predicate { $0.title == title },
//        sortBy: []
//    )
//    descriptor.fetchLimit = 1
//    do {
//        let results = try context.fetch(descriptor)
//        return results.first
//    } catch {
//        print("Failed to fetch DreamInterpretation by title: \(error)")
//        return nil
//    }
//}
