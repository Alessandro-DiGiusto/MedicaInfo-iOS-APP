//
//  DataLoader.swift
//  MedicaInfo
//
//  Created by Alessandro Di Giusto on 16/08/24.
//

import Foundation

class DataLoader {
    func loadComuni() -> [Comune] {
        guard let url = Bundle.main.url(forResource: "comuni", withExtension: "json") else {
            fatalError("File comuni.json non trovato")
        }
        
        do {
            let data = try Data(contentsOf: url)
            let comuni = try JSONDecoder().decode([Comune].self, from: data)
            return comuni.sorted(by: { $0.nome < $1.nome }) // Ordina per nome
        } catch {
            fatalError("Errore nel parsing dei dati: \(error)")
        }
    }
}
