import Foundation
import SwiftUI
import CoreData
import Combine

class PatientViewModel: ObservableObject {
    @Published var patient: Patient
    @Published var noteText: String
    @Published var selectedComuneNascita: Comune?
    
    @Published var comuni: [Comune] = []
    private var cancellables: Set<AnyCancellable> = []

    init(patient: Patient) {
        self.patient = patient
        self.noteText = patient.nota ?? ""
        loadComuni()
        self.selectedComuneNascita = comuni.first { $0.nome == patient.birthPlace }
    }

    func updateNoteText() {
        patient.nota = noteText
        saveContext()
        noteText = ""
    }

    private func saveContext() {
        do {
            try patient.managedObjectContext?.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }

    func loadComuni() {
        let loader = DataLoader()
        // Use the `@Published` property to update `comuni` with new data
        self.comuni = loader.loadComuni()
    }
}
