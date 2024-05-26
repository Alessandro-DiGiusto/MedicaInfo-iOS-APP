import SwiftUI
import CoreData
import UserNotifications

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
    
    @State private var amount: String = ""
    @FocusState private var amountIsFocused: Bool
    
    enum Gender: String, CaseIterable {
        case male = "Maschile"
        case female = "Femminile"
    }
    
    let availableConditions = [
        "Ipertensione", "Diabete", "Asma", "Artrite", "Micrania", "Obesità",
        "Sovrappeso", "Diabete di tipo 1", "Diabete di tipo 2", "Diabete M.O.D.Y",
        "Ipertensione", "Dislipidemia", "Sindrome metabolica", "Intolleranze alimentari",
        "Celiachia", "Allergie alimentari", "Dieta chetogenica", "Dieta mediterranea",
        "Dieta a basso contenuto di carboidrati", "Dieta a basso contenuto di grassi",
        "Ipercolesterolemia", "Ipertrigliceridemia", "Anemia da carenza di ferro",
        "Anemia megaloblastica", "Iperuricemia", "Malnutrizione", "Intolleranza al lattosio"
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                    .onTapGesture {
                        amountIsFocused = false
                    }
                
                VStack {
                    Form {
                        Section(header: Text("Informazioni Personali")) {
                            TextField("Nome", text: $name)
                                .focused($amountIsFocused)
                            TextField("Cognome", text: $surname)
                                .focused($amountIsFocused)
                            DatePicker("Data di Nascita", selection: $birthDate, displayedComponents: .date)
                            TextField("Codice Fiscale", text: $cf)
                                .focused($amountIsFocused)
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
                        
                        Section(header: Text("")) {
                                Button(action: saveData) {
                                    Text("Salva")
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .padding()
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                                
                                Button(action: {
                                    showDetailView.toggle()
                                }) {
                                    Text("Visualizza Dati Salvati")
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .padding()
                                        .background(Color.green)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }
                                .sheet(isPresented: $showDetailView) {
                                    DetailView(onDeleteAllPatients: deleteAllPatients)
                                        .environment(\.managedObjectContext, viewContext)
                                }
                            }
                            
                            Section(header: Text("Dev by alessandrodigiusto.it")) {
                            }
                    }
                    .navigationTitle("MedicaInfo")
                    .toolbar {
                        if amountIsFocused {
                            ToolbarItem(placement: .keyboard) {
                                Button("Done") {
                                    amountIsFocused = false
                                }
                            }
                        }
                    }
                    .toolbar {
                        ToolbarItem(placement: .bottomBar) {
                            HStack {
                                Spacer()
                                
                                // Primo tasto: Impostazioni
                                Button(action: {
                                    // Azione per il primo tasto
                                }) {
                                    Image(systemName: "gearshape.fill")
                                    Text("")
                                }
                                .padding()
                                
                                Spacer()
                                
                                // Secondo tasto: Profilo
                                Button(action: {
                                    // Azione per il secondo tasto
                                }) {
                                    Image(systemName: "person.fill")
                                    Text("")
                                }
                                .padding()
                                
                                Spacer()
                                
                                // Terzo tasto: Aggiungi
                                Button(action: {
                                    // Azione per il terzo tasto
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                    Text("")
                                }
                                .padding()
                                
                                Spacer()
                                
                                // Quarto tasto: Elenco
                                Button(action: {
                                    // Azione per il quarto tasto
                                }) {
                                    Image(systemName: "list.bullet")
                                    Text("")
                                }
                                .padding()
                                
                                Spacer()
                                
                                // Quinto tasto: Info
                                Button(action: {
                                    // Azione per il quinto tasto
                                }) {
                                    Image(systemName: "info.circle.fill")
                                    Text("")
                                }
                                .padding()
                                
                                Spacer()
                            }
                        }
                    }
                }
                .padding()
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
            scheduleNotificationAndShowAlert()
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

