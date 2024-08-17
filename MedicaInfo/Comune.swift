//
//  Comune.swift
//  MedicaInfo
//
//  Created by Alessandro Di Giusto on 16/08/24.
//

import Foundation

// Struttura per rappresentare un Comune
struct Comune: Identifiable, Codable, Hashable {  // Conformità a Hashable aggiunta
    let id = UUID()  // Identificatore unico per ogni Comune
    let nome: String // Nome del Comune
}
