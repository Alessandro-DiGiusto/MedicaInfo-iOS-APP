//
//  AddPatientFinalStepView.swift
//  MedicaInfo
//
//  Created by Alessandro Di Giusto on 12/08/24.
//

import Foundation
import SwiftUI

// Barra di ricerca personalizzata
struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack {
            TextField("Cerca paziente", text: $text)
                .foregroundColor(.primary)
                .padding(7)
                .background(Color(.systemGray5))
                .cornerRadius(10)
        }
        .padding(.vertical, 4)
    }
}
