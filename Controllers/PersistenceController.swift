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

    let container: NSPersistentContainer

    init() {
        container = NSPersistentContainer(name: "MedicalDataModel") 
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
    }
}
