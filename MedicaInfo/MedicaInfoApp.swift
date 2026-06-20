import SwiftUI
import CoreData
import SwiftData

@main
struct MedicaInfoApp: App {
    let persistenceController = PersistenceController.shared
    
/* //##########################################################################
    // USARE PER CACELLARE TUTTI I RECORD DEL DB
     init() {
        // Chiamata a deleteAllPatients() per eliminare tutti i dati dei pazienti all'avvio dell'app
        deleteAllPatients()
    } */
    
    // Funzione per eliminare tutti i dati dall'entità Patient
    func deleteAllPatients() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Patient")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try PersistenceController.shared.container.viewContext.execute(deleteRequest)
            try PersistenceController.shared.container.viewContext.save()
        } catch {
            print("Errore durante l'eliminazione dei dati: \(error)")
        }
    }
//##########################################################################
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
        .modelContainer(for: [DietPlan.self, Meal.self, FoodEntry.self])
    }
}
