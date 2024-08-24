//
//  DetailView.swift
//  MedicaInfo
//
//  Created by Alessandro Di Giusto on 02/06/24.
//

import Foundation
import SwiftUI
import CoreData

struct DetailView: View {
    @FetchRequest(
        entity: Patient.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Patient.name, ascending: true)]
    ) private var patients: FetchedResults<Patient>
    
    @State private var searchText: String = ""
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    @State private var selectedPatient: Patient?
    var onDeleteAllPatients: () -> Void
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGray6).edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    // Barra di ricerca sempre visibile
                    SearchBar(text: $searchText)
                        .padding(.horizontal)
                    
                    List {
                        ForEach(patients.filter { patient in
                            searchText.isEmpty || patient.name?.contains(searchText) == true
                        }) { patient in
                            PatientCardView(patient: patient)
                                .onTapGesture {
                                    selectedPatient = patient
                                }
                                .background(
                                    NavigationLink(
                                        destination: PatientDetailView(patient: patient, context: viewContext),
                                        isActive: Binding(
                                            get: { selectedPatient == patient },
                                            set: { if !$0 { selectedPatient = nil } }
                                        )
                                    ) {
                                        EmptyView()
                                    }
                                    .hidden() // Nascondere il NavigationLink
                                )
                        }
                        .listRowBackground(Color(.white))
                        .listRowSeparator(.hidden)
                    }
                    .listStyle(PlainListStyle())
                    
                    HStack {
                        Spacer()
                        if !patients.isEmpty {
                            Button(action: {
                                onDeleteAllPatients()
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                                    .font(.system(size: 24))
                                    .padding()
                            }
                        }
                        Spacer()
                    }
                    .padding()
                    .background(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: -5)
                }
            }
            .navigationBarTitle("")
            .navigationBarHidden(true)
        }
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        // Usa il contesto di CoreData fittizio per le anteprime
        let context = PersistenceController.preview.container.viewContext
        
        // Creare pazienti fittizi per il contesto
        let patient1 = Patient(context: context)
        patient1.name = "Mario"
        patient1.surname = "Rossi"
        patient1.cf = "MRARSS80A01H501X"
        
        let patient2 = Patient(context: context)
        patient2.name = "Luca"
        patient2.surname = "bi"
        patient2.cf = "LCABNC85C15H501D"
        
        return DetailView(onDeleteAllPatients: {})
            .environment(\.managedObjectContext, context)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
