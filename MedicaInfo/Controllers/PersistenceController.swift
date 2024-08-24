//
//  PersistenceController.swift
//  MedicaInfo
//
//  Created by Alessandro Di Giusto on 17/08/24.
//

//import Foundation
import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        // Crea oggetti di esempio nel contesto fittizio qui, se necessario
        
        do {
            try viewContext.save()
        } catch {
            // Gestione degli errori
            let nsError = error as NSError
            fatalError("Errore non risolto \(nsError), \(nsError.userInfo)")
        }
        
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "MedicalDataModel") // Assicurati che "MedicaInfo" sia il nome corretto del tuo modello CoreData
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                // Gestione degli errori
                fatalError("Errore non risolto \(error), \(error.userInfo)")
            }
        }
    }
}
