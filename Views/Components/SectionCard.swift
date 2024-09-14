//
//  AddPatientSecondStepView.swift
//  MedicaInfo
//
//  Created by Alessandro Di Giusto on 12/08/24.
//

import Foundation
import SwiftUI

struct SectionCard<Content: View>: View {
    let header: String
    let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(header)
                .font(.title2)
                .fontWeight(.bold)
                .padding(.bottom, 5)
            content()
        }
        .padding()
        .background(Color(.systemGroupedBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}
