//
//  AddPatientSecondStepView.swift
//  MedicaInfo
//
//  Created by Alessandro Di Giusto on 12/08/24.
//

import Foundation
import SwiftUI

struct AddPatientSecondStepView: View {
    @ObservedObject var viewModel: AddPatientViewModel
    @Binding var isActive: Bool
    
    var body: some View {
        Form {
            Section(header: Text("Anamnesi Sportiva")) {
                Toggle("Anamnesi Sportiva", isOn: $viewModel.sportAnamnesis)
                if viewModel.sportAnamnesis {
                    TextField("Sport richiesto", text: $viewModel.requiredSport)
                    TextField("Anni di pratica", value: $viewModel.yearsOfPractice, formatter: NumberFormatter())
                    TextField("Ore settimanali", value: $viewModel.weeklyHours, formatter: NumberFormatter())
                    Toggle("Pratica altri sport", isOn: $viewModel.practicesOtherSports)
                    if viewModel.practicesOtherSports {
                        TextField("Dettagli su altri sport", text: $viewModel.otherSportsDetails)
                    }
                    TextField("Sport praticati in passato", text: $viewModel.pastSports)
                }
            }
        }
        .navigationTitle("Step 2")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Indietro") {
                    isActive = false
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: AddPatientFinalStepView(viewModel: viewModel)) {
                    Text("Avanti")
                }
            }
        }
    }
}
