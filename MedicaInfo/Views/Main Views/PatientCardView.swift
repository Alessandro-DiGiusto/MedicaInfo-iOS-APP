//
//  AddPatientFirstStepView.swift
//  MedicaInfo
//
//  Created by Alessandro Di Giusto on 12/08/24.
//

import Foundation
import SwiftUI


// Card del paziente
struct PatientCardView: View {
    var patient: Patient

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 50, height: 50)
                .foregroundColor(.blue)

            VStack(alignment: .leading, spacing: 4) {
                Text(patient.name ?? "Unknown Name")
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(patient.surname ?? "Unknown Surname")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
        .padding(.vertical, 4)
        .padding(.horizontal)
    }
}
