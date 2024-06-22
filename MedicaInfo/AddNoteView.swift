//
//  AddNoteView.swift
//  MedicaInfo
//
//  Created by Alessandro Di Giusto on 31/05/24.
//

import Foundation
import SwiftUI
import CoreData

struct AddNoteView: View {
    let patientId: NSManagedObjectID
    let conditions: String?
    let onDismiss: () -> Void

    @State private var noteText: String = ""

    var body: some View {
        NavigationView {
            VStack {
                Text("Aggiungi Nota")
                    .font(.title)
                    .padding()

                TextEditor(text: $noteText)
                    .frame(minHeight: 200)
                    .padding()

                Button("Salva") {
                    // Salvare la nota e aggiornare eventualmente il Core Data
                    // qui utilizzando patientId e noteText
                    // E poi chiudi la vista
                    onDismiss()
                }
                .padding()
                .disabled(noteText.isEmpty)
            }
            .navigationBarItems(trailing: Button("Annulla") {
                onDismiss()
            })
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Aggiungi Nota")
        }
    }
}
