//
//  AddPatientFinalStepView.swift
//  MedicaInfo
//
//  Created by Alessandro Di Giusto on 12/08/24.
//

import Foundation
import SwiftUI

struct AddPatientFinalStepView: View {
    @ObservedObject var viewModel: AddPatientViewModel
    
    var body: some View {
        Form {
            Section(header: Text("Condizioni Mediche")) {
                Toggle("Diabete Mellito", isOn: $viewModel.diabetesMellitus)
                Toggle("Malattie di Cuore", isOn: $viewModel.heartDisease)
                Toggle("Malattie Tiroidee", isOn: $viewModel.thyroidDiseases)
                Toggle("Morte Improvvisa", isOn: $viewModel.suddenDeath)
                Toggle("Malattie Polmonari", isOn: $viewModel.pulmonaryDiseases)
                Toggle("Infarto del Miocardio", isOn: $viewModel.myocardialInfarction)
                Toggle("Cardiomiopatie", isOn: $viewModel.cardiomyopathies)
                Toggle("Ipertensione", isOn: $viewModel.hypertension)
                Toggle("Colesterolo Alto", isOn: $viewModel.highCholesterol)
                Toggle("Celiachia", isOn: $viewModel.celiacDisease)
                Toggle("Ictus/Malattie Neurologiche", isOn: $viewModel.strokeNeurological)
                Toggle("Tumori", isOn: $viewModel.tumors)
                Toggle("Asma/Allergie", isOn: $viewModel.asthmaAllergies)
                Toggle("Obesità", isOn: $viewModel.obesity)
                Toggle("Malattie Genetiche", isOn: $viewModel.geneticDiseases)
            }
        }
        .navigationTitle("Step 3")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Indietro") {
                    // Implementa la navigazione indietro se necessario
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Salva") {
                    viewModel.savePatient()
                }
            }
        }
    }
}
