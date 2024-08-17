//
//  AddPatientFirstStepView.swift
//  MedicaInfo
//
//  Created by Alessandro Di Giusto on 12/08/24.
//

import Foundation
import SwiftUI

struct AddPatientFirstStepView: View {
    @ObservedObject var viewModel: AddPatientViewModel
    @Binding var isActive: Bool
    
    var body: some View {
        Form {
            Section(header: Text("Dati Personali")) {
                TextField("Nome", text: $viewModel.name)
                TextField("Cognome", text: $viewModel.surname)
                DatePicker("Data di Nascita", selection: $viewModel.birthDate, displayedComponents: .date)
                TextField("Codice Fiscale", text: $viewModel.cf)
                TextField("Genere", text: $viewModel.gender)
                TextField("Indirizzo di Residenza", text: $viewModel.residenceAddress)
                TextField("Telefono", text: $viewModel.tel)
                //TextField("Condizioni", text: $viewModel.conditions)
                //TextField("Nota", text: $viewModel.nota)
            }
        }
        .navigationTitle("Step 1")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink(destination: AddPatientSecondStepView(viewModel: viewModel, isActive: $isActive)) {
                    Text("Avanti")
                }
            }
        }
    }
}
