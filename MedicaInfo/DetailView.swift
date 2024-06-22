//
//  DetailView.swift
//  MedicaInfo
//
//  Created by Alessandro Di Giusto on 31/05/24.
//

import Foundation
import SwiftUI
import CoreData

struct IdentifiableManagedObjectID: Identifiable {
    let id: NSManagedObjectID
}

struct DetailView: View {
    @FetchRequest(entity: Patient.entity(), sortDescriptors: [])
    private var patients: FetchedResults<Patient>
    var onDeleteAllPatients: () -> Void
    @State private var expandedPatientId: NSManagedObjectID?
    @State private var searchText: String = ""
    @State private var isSearching: Bool = false
    @State private var addingNoteForPatientId: IdentifiableManagedObjectID? // Cambiamento qui
    @State private var selectedPatient: Patient?

    var body: some View {
        NavigationView {
            content
        }
    }

    var content: some View {
        VStack {
            Text("Lista Pazienti")
                .bold()
                .padding(.top, 16) // Aggiungi spaziatura sopra
            searchView
            patientsListView
            toolbar
            Spacer()
        }
        .background(Color(.systemGray6))
    }

    var searchView: some View {
        if isSearching {
            return AnyView(
                HStack {
                    TextField("Cerca per nome o cognome", text: $searchText)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 10)
                        .background(Color(.white))
                        .cornerRadius(8)
                        //.padding(.horizontal, 10)

                    Button("Annulla") {
                        searchText = ""
                        isSearching = false
                        hideKeyboard()
                    }
                    .padding(.trailing, 10)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .transition(.move(edge: .top))
                //.animation(.default, value: isSearching)
            )
        } else {
            return AnyView(EmptyView())
        }
    }

    var patientsListView: some View {
        List {
            ForEach(filteredPatients, id: \.self) { patient in
                NavigationLink(destination: PatientDetailView(patient: patient, dateFormatter: dateFormatter)) {
                    VStack(alignment: .leading) {
                        Text("\(patient.name ?? "Nessun nome inserito") \(patient.surname ?? "Nessun Cognome inserito")")
                            .font(.headline)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                            if expandedPatientId == patient.objectID {
                                expandedPatientId = nil
                            } else {
                                expandedPatientId = patient.objectID
                            }
                    }
                    .onLongPressGesture {
                        addingNoteForPatientId = IdentifiableManagedObjectID(id: patient.objectID)
                        selectedPatient = patient
                    }

                    if expandedPatientId == patient.objectID {
                        Text("Data di Nascita: \(patient.birthDate ?? Date(), formatter: dateFormatter)")
                        Text("Contatto: \(patient.tel ?? "Nessun Contatto inserito")")
                        Text("Codice Fiscale: \(patient.cf ?? "Nessun CF inserito")")
                        Group {
                            Text("Condizioni Mediche:")
                                .font(.headline)
                            ForEach(patient.conditions?.components(separatedBy: ", ") ?? [], id: \.self) { condition in
                                Text("⚠️ \(condition)")
                            }
                        }
                        // Aggiungi altre informazioni e funzionalità di modifica qui
                    }
                }
                .padding(.vertical, 8)
                .contextMenu {
                    Button(action: {
                        addingNoteForPatientId = IdentifiableManagedObjectID(id: patient.objectID)
                        selectedPatient = patient
                    }) {
                        Text("Aggiungi Nota")
                        Image(systemName: "note.text")
                    }
                }
                .gesture(
                    DragGesture()
                        .onEnded { value in
                            if value.translation.width > 100 {
                                addingNoteForPatientId = IdentifiableManagedObjectID(id: patient.objectID)
                                selectedPatient = patient
                            }
                        }
                )
            }
        }
    }




    var toolbar: some View {
        HStack {
            Spacer()
            Button(action: {
                isSearching.toggle()
            }) {
                Image(systemName: "magnifyingglass")
                    .imageScale(.large)
            }
            .padding()
            Spacer()
            
            Button(action: {
                onDeleteAllPatients()
            }) {
                Image(systemName: "trash")
                .imageScale(.large)
            }
            .padding()
            Spacer()
        }
    }

    var filteredPatients: [Patient] {
        if searchText.isEmpty {
            return Array(patients)
        } else {
            return patients.filter {
                ($0.name?.localizedCaseInsensitiveContains(searchText) ?? false) ||
                ($0.surname?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
 }
