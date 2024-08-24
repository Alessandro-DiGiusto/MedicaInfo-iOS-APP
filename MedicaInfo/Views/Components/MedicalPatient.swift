//
//  Patient.swift
//  MedicaInfo
//
//  Created by Alessandro Di Giusto on 24/08/24.
//

import Foundation
struct Patient {
    var name: String?
    var surname: String?
    var birthDate: Date?
    var tel: String?
    
    // Costruttore con parametri opzionali
    init(name: String? = nil, surname: String? = nil, birthDate: Date? = nil, tel: String? = nil) {
        self.name = name
        self.surname = surname
        self.birthDate = birthDate
        self.tel = tel
    }
}
