//
//  DetailRow.swift
//  MedicaInfo
//
//  Created by Alessandro Di Giusto on 18/08/24.
//

import Foundation
import SwiftUI

// Riga di dettaglio
struct DetailRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .font(.body)
                .foregroundColor(.primary)
        }
        .padding(.vertical, 4)
    }
}
