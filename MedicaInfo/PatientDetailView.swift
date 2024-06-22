//
//  PatientDetailView.swift
//  MedicaInfo
//
//  Created by Alessandro Di Giusto on 31/05/24.
//

import Foundation
import SwiftUI
import CoreData
import UserNotifications
import UIKit
import WebKit
import PDFKit

struct PatientDetailView: View {
    let patient: Patient
    let dateFormatter: DateFormatter
    @State private var noteText: String = ""

    init(patient: Patient, dateFormatter: DateFormatter) {
        self.patient = patient
        self.dateFormatter = dateFormatter
    }
    
    var body: some View {
        Spacer()
        HStack {
            Text(patient.name ?? "Nessun nome inserito")
            Text(patient.surname ?? "Nessun surname inserito")
        }
        .bold()
        
        Section(header: Text("Anagrafica")) {
            VStack {
                // Altre view sopra lo sfondo
                // Section Anagrafica con effetto vetro
                VStack {
                    Divider()
                    Text("Data di Nascita: \(patient.birthDate ?? Date(), formatter: dateFormatter)")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Divider()
                    Text("Codice Fiscale: \(patient.cf ?? "N/A")")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Divider()
                    
                    HStack{
                        Text("Sesso:")
                            .bold()
                        Text(patient.gender ?? "Nessun gender inserito")
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Divider()
                    Text("Contatto: \(patient.tel ?? "Nessun Contatto inserito")")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Divider()
                    
                    Group {
                        Text("Condizioni Mediche:")
                            .font(.headline)
                        ForEach(patient.conditions?.components(separatedBy: ", ") ?? [], id: \.self) { condition in
                            Text("⚠️ \(condition)")
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    
                    
                    
                    // Aggiungi un campo per le note
                    Spacer()
                    TextField("Aggiungi una nota", text: $noteText)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    
                    // Aggiungi un pulsante per salvare la nota
                    Button("Salva Nota") {
                        // Qui aggiungi la logica per salvare la nota nel database o dove preferisci
                    }
                    .padding()
                    
                    Spacer()
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .navigationBarTitle("Dettagli Paziente")
            }
        }
            }//fine section
        }
