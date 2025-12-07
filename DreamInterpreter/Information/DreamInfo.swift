//
//  DreamInfo.swift
//  DreamInterpreter
//
//  Created by John Martino on 12/7/25.
//

import Foundation

struct ArchetypeInfo: Codable, Identifiable {
    var id: String { name }
    let name: String
    let description: String
}

struct CategoryInfo: Codable, Identifiable {
    var id: String { name }
    let name: String
    let archetypes: [ArchetypeInfo]
}

struct DreamInfo: Codable {
    let categories: [CategoryInfo]
}
