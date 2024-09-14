//
//  Item.swift
//  MedicaInfo
//
//  Created by Alessandro Di Giusto on 22/05/24.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
