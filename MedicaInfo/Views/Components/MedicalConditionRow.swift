//
//  MedicalConditionRow.swift
//  MedicaInfo
//
//  Created by Alessandro Di Giusto on 18/08/24.
//

import Foundation
import SwiftUI

// Riga per le condizioni mediche
struct MedicalConditionRow: View {
    let condition: String
    let isPresent: Bool

    var body: some View {
        if isPresent {
            HStack {
                Text("⚠️ \(condition)")
                    .font(.body)
                    .foregroundColor(.red)
                Spacer()
            }
            .padding(.vertical, 4)
        }
    }
}
