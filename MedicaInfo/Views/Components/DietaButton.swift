//
//  DietaButton.swift
//  MedicaInfo
//
//  Created by Alessandro Di Giusto on 25/08/24.
//

import Foundation
import SwiftUI

struct DietaButton: View {
    let title: String
    @Binding var selectedOption: String
    let optionValue: String
    
    var body: some View {
        Button(action: {
            selectedOption = optionValue
        }) {
            HStack {
                Text(title)
                Spacer()
                Image(systemName: selectedOption == optionValue ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(.blue)
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).stroke(selectedOption == optionValue ? Color.blue : Color.gray, lineWidth: 2))
        }
        .buttonStyle(PlainButtonStyle())
    }
}
