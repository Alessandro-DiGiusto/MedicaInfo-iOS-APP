//
//  AddPatientView.swift
//  MedicaInfo
//
//  Created by Alessandro Di Giusto on 12/08/24.
//

import SwiftUI
import CoreData

struct AddPatientView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var viewModel: AddPatientViewModel
    
    @State private var showSuggestions: Bool = false
    @State private var showAlert: Bool = false  // Stato per mostrare l'alert di conferma
    @State private var showSuccessMessage: Bool = false  // Stato per mostrare il messaggio di successo
    
    init() {
        _viewModel = StateObject(wrappedValue: AddPatientViewModel(context: PersistenceController.shared.container.viewContext))
    }
    
    private let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        return formatter
    }()
    
    var body: some View {
        ZStack {
            ZStack {
                VStack {
                    Form {
                        Section(header: Text("Dati Personali")
                            .font(.headline)
                            .foregroundColor(.blue)) {
                                HStack {
                                    Image(systemName: "person")
                                        .foregroundColor(.blue)
                                    TextField("Nome", text: $viewModel.name)
                                }
                                HStack {
                                    Image(systemName: "person.fill")
                                        .foregroundColor(.blue)
                                    TextField("Cognome", text: $viewModel.surname)
                                }
                                HStack {
                                    Image(systemName: "calendar")
                                        .foregroundColor(.blue)
                                    HStack {
                                        Text("Data di Nascita")
                                            .foregroundColor(.black) // Colore del testo per "Data di Nascita"
                                        Spacer() // Spazio tra il testo e la data selezionata
                                        
                                        // Il DatePicker vero e proprio
                                        DatePicker("", selection: $viewModel.birthDate, displayedComponents: .date)
                                            .labelsHidden() // Nasconde l'etichetta del DatePicker
                                            .accentColor(.blue)
                                    }
                                    .contentShape(Rectangle()) // Espande l'area tappabile
                                    .onTapGesture {
                                        // Quando l'area viene cliccata, attiva il DatePicker
                                        UIApplication.shared.endEditing()  // Nasconde la tastiera se aperta
                                        // Puoi anche forzare il focus sul DatePicker, ma di solito basta il TapGesture
                                    }
                                }
                                
                                HStack {
                                    Image(systemName: "barcode.viewfinder")
                                        .foregroundColor(.blue)
                                    TextField("Codice Fiscale", text: Binding(
                                        get:{
                                            viewModel.cf.uppercased() // Ritorna il testo in maiuscolo
                                        },
                                        set: {
                                            viewModel.cf = $0.uppercased() // Converte il testo in maiuscolo mentre l'utente scrive
                                        }
                                    ))
                                }
                                
                                Picker("Sesso", selection: $viewModel.gender) {
                                    Text("Maschile").tag("Maschile")
                                    Text("Femminile").tag("Femminile")
                                }
                                .pickerStyle(SegmentedPickerStyle())
                                .padding(.vertical)
                                
                                HStack {
                                    Image(systemName: "location")
                                        .foregroundColor(.blue)
                                    TextField("Inserisci Comune di Nascita", text: $viewModel.birthPlace, onEditingChanged: { isEditing in
                                        if isEditing {
                                            showSuggestions = true
                                        }
                                    })
                                }
                                
                                if showSuggestions && !viewModel.filteredComuni.isEmpty {
                                    List(viewModel.filteredComuni, id: \.id) { comune in
                                        Text(comune.nome)
                                            .onTapGesture {
                                                viewModel.birthPlace = comune.nome
                                                showSuggestions = false  // Nascondi i suggerimenti dopo la selezione
                                            }
                                    }
                                    .frame(height: 20)  // Limita l'altezza della lista dei suggerimenti
                                }
                                
                                HStack {
                                    Image(systemName: "house")
                                        .foregroundColor(.blue)
                                    TextField("Indirizzo di Residenza", text: $viewModel.residenceAddress)
                                }
                                HStack {
                                    Image(systemName: "phone")
                                        .foregroundColor(.blue)
                                    TextField("Telefono", text: $viewModel.tel)
                                        .keyboardType(.phonePad)
                                }
                            }
                        
                        Section(header: Text("Anamnesi Sportiva")
                            .font(.headline)
                            .foregroundColor(.blue)) {
                                Toggle("Anamnesi Sportiva", isOn: $viewModel.sportAnamnesis)
                                if viewModel.sportAnamnesis {
                                    HStack {
                                        Image(systemName: "sportscourt")
                                            .foregroundColor(.blue)
                                        TextField("Sport per il quale è richiesta la visita:", text: $viewModel.requiredSport)
                                    }
                                    
                                    HStack {
                                        Image(systemName: "clock")
                                            .foregroundColor(.blue)
                                        Text("Da quanti anni pratica questo sport?")
                                        Spacer()
                                        TextField("Anni di pratica", value: Binding(
                                            get: { viewModel.yearsOfPractice ?? 0 },
                                            set: { viewModel.yearsOfPractice = $0 == 0 ? nil : $0 }
                                        ), formatter: numberFormatter)
                                        .keyboardType(.numberPad)
                                        .frame(width: 50)
                                    }
                                    
                                    HStack {
                                        Image(systemName: "hourglass")
                                            .foregroundColor(.blue)
                                        Text("Quante ore dedica alla settimana?")
                                        Spacer()
                                        TextField("Ore settimanali", value: Binding(
                                            get: { viewModel.weeklyHours ?? 0 },
                                            set: { viewModel.weeklyHours = $0 == 0 ? nil : $0 }
                                        ), formatter: numberFormatter)
                                        .keyboardType(.numberPad)
                                        .frame(width: 50)
                                    }
                                    
                                    Toggle("Pratica altri sport", isOn: $viewModel.practicesOtherSports)
                                    if viewModel.practicesOtherSports {
                                        HStack {
                                            Image(systemName: "ellipsis.circle")
                                                .foregroundColor(.blue)
                                            TextField("Dettagli su altri sport", text: $viewModel.otherSportsDetails)
                                        }
                                    }
                                    HStack {
                                        Image(systemName: "archivebox")
                                            .foregroundColor(.blue)
                                        TextField("Sport praticati in passato", text: $viewModel.pastSports)
                                    }
                                }
                            }
                        
                        Section(header: Text("Condizioni Mediche")
                            .font(.headline)
                            .foregroundColor(.blue)) {
                                Toggle("Diabete Mellito", isOn: $viewModel.diabetesMellitus)
                                Toggle("Malattie di Cuore", isOn: $viewModel.heartDisease)
                                Toggle("Malattie Tiroidee", isOn: $viewModel.thyroidDiseases)
                                Toggle("Morte Improvvisa", isOn: $viewModel.suddenDeath)
                                Toggle("Malattie Polmonari", isOn: $viewModel.pulmonaryDiseases)
                                Toggle("Infarto del Miocardio", isOn: $viewModel.myocardialInfarction)
                                Toggle("Cardiomiopatie", isOn: $viewModel.cardiomyopathies)
                                Toggle("Ipertensione", isOn: $viewModel.hypertension)
                                Toggle("Colesterolo Alto", isOn: $viewModel.highCholesterol)
                                Toggle("Celiachia", isOn: $viewModel.celiacDisease)
                                Toggle("Ictus/Malattie Neurologiche", isOn: $viewModel.strokeNeurological)
                                Toggle("Tumori", isOn: $viewModel.tumors)
                                Toggle("Asma/Allergie", isOn: $viewModel.asthmaAllergies)
                                Toggle("Obesità", isOn: $viewModel.obesity)
                                Toggle("Malattie Genetiche", isOn: $viewModel.geneticDiseases)
                            }
                    }
                    .padding(.top)
                    
                    Spacer()
                    
                    Button(action: {
                        UIApplication.shared.endEditing()  // Nascondi la tastiera
                        viewModel.savePatient()
                        showSuccessMessage = true  // Mostra il messaggio di successo
                        
                        // Nasconde il messaggio dopo un ritardo e torna alla schermata iniziale
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            withAnimation {
                                showSuccessMessage = false
                            }
                            // Dopo che l'animazione termina, torna alla schermata iniziale
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                    }) {
                        Text("Salva Paziente")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
                .background(Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all))
                .navigationTitle("Aggiungi Paziente")
                .onTapGesture {
                    UIApplication.shared.endEditing()  // Nascondi la tastiera quando si tocca fuori dai campi di testo
                }
                .onAppear {
                    // Carica i comuni se non sono stati già caricati
                    if viewModel.comuni.isEmpty {
                        viewModel.loadComuni()
                    }
                }
                
                // Overlay per il messaggio di successo
                if showSuccessMessage {
                    VStack {
                        Text("✅ Salvato")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(10)
                    }
                    .frame(width: 300, height: 100)
                    //.background(Color.black.opacity(0.7))
                    .cornerRadius(20)
                    .shadow(radius: 20)
                    .transition(.opacity)
                    .zIndex(1)  // Assicurati che l'overlay sia in cima a tutto
                }
            }
        }
    }
}
