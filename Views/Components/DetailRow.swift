//
//  DetailRow.swift
//  MedicaInfo
//
//  Created by Alessandro Di Giusto on 18/08/24.
//

import Foundation
import SwiftUI

// Riga di dettaglio
// Componenti di Supporto

struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
            Spacer()
            Text(value)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 2)
    }
}
