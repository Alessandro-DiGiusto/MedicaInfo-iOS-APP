//
//  PDFKitRepresentedView.swift
//  MedicaInfo
//
//  Created by Alessandro Di Giusto on 18/08/24.
//

import Foundation
import SwiftUI
import PDFKit

// Supponiamo che esista un componente PDFKitRepresentedView
// Wrapper per integrare PDFKit in SwiftUI
struct PDFKitRepresentedView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.document = PDFDocument(url: url)
        pdfView.autoScales = true
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: Context) {
        // Non è necessario aggiornare nulla
    }
}
