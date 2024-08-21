//
//  UIApplication+Extensions.swift
//  MedicaInfo
//
//  Created by Alessandro Di Giusto on 17/08/24.
//

import Foundation
import SwiftUI

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
