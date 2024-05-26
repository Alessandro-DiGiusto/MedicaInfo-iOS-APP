//
//  ContentView.swift
//  MedicaInfo
//
//  Created by Alessandro Di Giusto on 22/05/24.
//

import SwiftUI
import CoreData
import UserNotifications

// Definizione di RadioButtonField
struct RadioButtonField: View {
    let id: ContentView.Gender
    let label: String
    let callback: (ContentView.Gender) -> ()
    let isMarked: Bool
    
    var body: some View {
        Button(action: {
            self.callback(self.id)
        }) {
            HStack(alignment: .center) {
                Image(systemName: isMarked ? "largecircle.fill.circle" : "circle")
                    .foregroundColor(isMarked ? Color.blue : Color.primary)
                Text(label)
                    .foregroundColor(Color.primary)
                Spacer()
            }
        }
        .foregroundColor(Color.white)
    }
}

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(entity: Patient.entity(), sortDescriptors: [])
    private var patients: FetchedResults<Patient>

    @State private var name: String = ""
    @State private var surname: String = ""
    @State private var birthDate: Date = Date()
    @State private var cf: String = ""
    @State private var selectedGender: Gender = .male
    @State private var selectedConditionIndex: Int = 0
    @State private var conditions: [String] = []
    @State private var showDetailView = false
    @State private var showConfirmationAlert = false
    
    @State private var isKeyboardHidden = true // Aggiunto stato per gestire la visibilità della tastiera
    
    enum Gender: String, CaseIterable {
        case male = "Maschile"
        case female = "Femminile"
    }

    let availableConditions = [
        "Ipertensione",
        "Diabete",
        "Asma",
        "Artrite",
        "Micrania",
        "Obesità",
        "Sovrappeso",
        "Diabete di tipo 1",
        "Diabete di tipo 2",
        "Diabete M.O.D.Y",
        "Ipertensione",
        "Dislipidemia",
        "Sindrome metabolica",
        "Intolleranze alimentari",
        "Celiachia",
        "Allergie alimentari",
        "Dieta chetogenica",
        "Dieta mediterranea",
        "Dieta a basso contenuto di carboidrati",
        "Dieta a basso contenuto di grassi",
        "Ipercolesterolemia",
        "Ipertrigliceridemia",
        "Anemia da carenza di ferro",
        "Anemia megaloblastica",
        "Iperuricemia",
        "Malnutrizione",
        "Intolleranza al lattosio"
    ]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Informazioni Personali")) {
                    TextField("Nome", text: $name)
                    TextField("Cognome", text: $surname)
                    DatePicker("Data di Nascita", selection: $birthDate, displayedComponents: .date)
                    TextField("Codice Fiscale", text: $cf)
                    
                    HStack {
                        Text("Sesso")
                        Spacer()
                        Picker("Gender", selection: $selectedGender) {
                            ForEach(Gender.allCases, id: \.self) { gender in
                                Text(gender.rawValue)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                }
                
                Section(header: Text("Condizioni Mediche")) {
                    VStack {
                        Picker("Condizioni Rilevanti", selection: $selectedConditionIndex) {
                            ForEach(0..<availableConditions.count, id: \.self) {
                                Text(availableConditions[$0])
                            }
                        }
                        .pickerStyle(DefaultPickerStyle())
                        .onChange(of: selectedConditionIndex) { newValue in
                            addCondition(newValue)
                        }
                        
                        if !conditions.isEmpty {
                            Text("Patologie selezionate:")
                            ForEach(conditions, id: \.self) { condition in
                                Text(condition)
                            }
                        }
                    }
                }
                
                Button(action: saveData) {
                    Text("Salva")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                
                Button(action: {
                    showDetailView.toggle()
                }) {
                    Text("Visualizza Dati Salvati")
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .sheet(isPresented: $showDetailView) {
                    DetailView(onDeleteAllPatients: deleteAllPatients)
                        .environment(\.managedObjectContext, viewContext)
                }
            }
            .navigationTitle("MedicaInfo")
        }
        .alert(isPresented: $showConfirmationAlert) {
            Alert(
                title: Text("Salvataggio completato"),
                message: Text("I dati sono stati salvati con successo."),
                dismissButton: .default(Text("OK")) {
                    clearForm()
                }
            )
        }
    }
    
    private func addCondition(_ index: Int) {
        let condition = availableConditions[index]
        conditions.append(condition)
    }

    private func saveData() {
        let newPatient = Patient(context: viewContext)
        newPatient.name = name
        newPatient.surname = surname
        newPatient.birthDate = birthDate
        newPatient.cf = cf
        newPatient.conditions = conditions.joined(separator: ", ")
        newPatient.gender = selectedGender.rawValue

        do {
            try viewContext.save()
            //clearForm()
            scheduleNotificationAndShowAlert() // Aggiunta della chiamata alla funzione scheduleNotification
        } catch {
            print("Failed to save data: \(error)")
        }
    }

    private func scheduleNotificationAndShowAlert() {
        scheduleNotification()
        showConfirmationAlert = true
    }
    
    private func scheduleNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Salvataggio completato"
        content.body = "I dati sono stati salvati con successo."

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }
    
    private func clearForm() {
        name = ""
        surname = ""
        birthDate = Date()
        cf = ""
        conditions = []
        selectedGender = .male
    }
    
    private func deleteAllPatients() {
        for patient in patients {
            viewContext.delete(patient)
        }
        
        do {
            try viewContext.save()
        } catch {
            print("Failed to delete all patients: \(error)")
        }
    }
}
