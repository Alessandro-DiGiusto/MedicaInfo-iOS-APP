import Foundation
import CoreData

class PatientViewModel: ObservableObject {
    @Published var patient: Patient
    @Published var noteText: String = ""
    var context: NSManagedObjectContext
    
    init(patient: Patient, context: NSManagedObjectContext) {
        self.patient = patient
        self.context = context
        self.noteText = patient.nota ?? ""
    }
    
    var pdfFileURL: URL? {
        if let path = patient.pdfFilePath {
            return URL(fileURLWithPath: path)
        }
        return nil
    }
    
    func savePDF(url: URL) {
        do {
            // Inizia ad accedere alla risorsa sicura
            let hasAccess = url.startAccessingSecurityScopedResource()
            defer {
                if hasAccess {
                    url.stopAccessingSecurityScopedResource()
                }
            }

            // Ottieni la directory dei documenti dell'app
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            
            // Crea una nuova destinazione per il file PDF
            let destinationURL = documentsDirectory.appendingPathComponent(url.lastPathComponent)
            
            // Copia il file PDF nella directory dei documenti
            try FileManager.default.copyItem(at: url, to: destinationURL)
            
            // Salva il percorso del file PDF nel modello Patient
            self.patient.pdfFilePath = destinationURL.path
            
            // Salva il contesto di Core Data
            try self.context.save()
            
            print("PDF salvato con successo.")
        } catch {
            print("Errore durante il salvataggio del PDF: \(error.localizedDescription)")
        }
    }



    
    func removePDF() {
        if let path = patient.pdfFilePath {
            let fileManager = FileManager.default
            let filePath = URL(fileURLWithPath: path)
            do {
                try fileManager.removeItem(at: filePath)
                patient.pdfFilePath = nil
                try context.save()
                print("PDF rimosso con successo.")
            } catch {
                print("Errore durante la rimozione del PDF: \(error.localizedDescription)")
            }
        }
    }
    
    func saveNote() {
        patient.nota = noteText
        do {
            try context.save()
        } catch {
            print("Errore durante il salvataggio della nota: \(error)")
        }
    }
}
