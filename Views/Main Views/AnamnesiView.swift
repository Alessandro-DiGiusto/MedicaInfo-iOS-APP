import SwiftUI
import CoreData

struct AnamnesiView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var patient: Patient

    @State private var residenceAddress: String = ""

    var body: some View {
        Form {
            Section(header: Text("Indirizzo di Residenza")) {
                TextField("Indirizzo", text: $residenceAddress)
            }
            Button("Salva") {
                saveAnamnesiData()
            }
        }
        .onAppear {
            // Pre-fill the address if it exists in the patient record
            residenceAddress = patient.residenceAddress ?? ""
        }
    }

    private func saveAnamnesiData() {
        patient.residenceAddress = residenceAddress

        do {
            try viewContext.save()
            // Gestisci navigazione o alert se necessario
        } catch {
            print("Errore nel salvataggio dei dati anamnestici: \(error)")
        }
    }
}
