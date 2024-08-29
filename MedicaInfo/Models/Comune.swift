//
//  Comune.swift
//  MedicaInfo
//
//  Created by Alessandro Di Giusto on 16/08/24.
//

import Foundation

struct Comune: Identifiable, Codable, Hashable {
    let id: UUID  // Identificatore unico per ogni Comune
    let nome: String // Nome del Comune

    init(id: UUID = UUID(), nome: String) {
        self.id = id
        self.nome = nome
    }

    enum CodingKeys: String, CodingKey {
        case nome
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.nome = try container.decode(String.self, forKey: .nome)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(nome, forKey: .nome)
    }
}
