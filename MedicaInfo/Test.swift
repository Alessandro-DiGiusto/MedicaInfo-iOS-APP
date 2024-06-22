//
//  Test.swift
//  MedicaInfo
//
//  Created by Alessandro Di Giusto on 02/06/24.
//

import Foundation
import SwiftUI
import CoreData

struct Test: View {
    @FetchRequest(entity: Patient.entity(), sortDescriptors: [])
    private var patients: FetchedResults<Patient>
    var onDeleteAllPatients: () -> Void

    var body: some View {
        NavigationView {
            List {
                ForEach(patients) { patient in
                    VStack(alignment: .leading) {
                        Text(patient.name ?? "Nessun nome inserito")
                            .font(.headline)
                        Text(patient.surname ?? "Nessun Cognome inserito")
                            .font(.headline)
                        Text("Data di Nascita: \(patient.birthDate ?? Date(), formatter: dateFormatter)")
                        
                        Group {
                            Text("Condizioni Mediche:")
                                .font(.headline)
                            ForEach(patient.conditions?.components(separatedBy: ", ") ?? [], id: \.self) { condition in
                                Text("⚠️ \(condition)")
                            }
                        }
                        
                        Text("Codice Fiscale:\n \(patient.cf ?? "Nessun CF inserito")")
                    }
                }
            }
            .navigationTitle("Dati Salvati")
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button(action: {
                        onDeleteAllPatients()
                    }) {
                        HStack {
                            Image(systemName: "trash")
                            Text("Elimina tutti i pazienti")
                        }
                    }
                }
            }
        }
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
}
