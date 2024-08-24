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
    @State private var showAlert: Bool = false
    @State private var showSuccessMessage: Bool = false
    
    // Variabili per Anamnesi Fisiologica
    @State private var partoNaturale: String = ""
    @State private var vaccinazioni: String = ""
    
    @State private var assumeFarmaci: Bool = false
    @State private var qualiFarmaci: String = ""
    @State private var esamiSangue: Bool = false
    @State private var alterazioniEsamiSangue: String = ""
    
    @State private var dieta: String = ""
    @State private var dietaSpeciale: String = ""
    @State private var fumo: String = ""
    @State private var quanteSigarette: String = ""
    @State private var beveAlcolici: Bool = false
    @State private var consumoAlcol: String = ""
    @State private var beveCaffe: Bool = false
    @State private var consumoCaffe: String = ""
    @State private var etaMestruazione: Decimal = 0
    @State private var dataUltimaMestruazione: Date = Date()
    @State private var anomalieCiclo: Bool = false
    @State private var noteAnomalieCiclo: String = ""
    @State private var gravidanze: Bool = false
    
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
            VStack {
                Form {
                    personalDataSection
                    sportAnamnesisSection
                    medicalConditionsSection
                    physiologicalAnamnesisSection
                }
                .padding(.top)
                
                Spacer()
                
                saveButton
            }
            .background(Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all))
            .navigationTitle("Aggiungi Paziente")
            .onTapGesture {
                UIApplication.shared.endEditing()
            }
            .onAppear {
                if viewModel.comuni.isEmpty {
                    viewModel.loadComuni()
                }
            }
            
            if showSuccessMessage {
                successOverlay
            }
        }
    }
    
    // Sezione Dati Personali
    var personalDataSection: some View {
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
                            .foregroundColor(.black)
                        Spacer()
                        DatePicker("", selection: $viewModel.birthDate, displayedComponents: .date)
                            .labelsHidden()
                            .accentColor(.blue)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        UIApplication.shared.endEditing()
                    }
                }
                HStack {
                    Image(systemName: "barcode.viewfinder")
                        .foregroundColor(.blue)
                    TextField("Codice Fiscale", text: Binding(
                        get: {
                            viewModel.cf.uppercased()
                        },
                        set: {
                            viewModel.cf = $0.uppercased()
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
                                showSuggestions = false
                            }
                    }
                    .frame(height: 20)
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
    }
    
    // Sezione Anamnesi Sportiva
    var sportAnamnesisSection: some View {
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
    }
    
    // Sezione Condizioni Mediche
    var medicalConditionsSection: some View {
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
    
    // Sezione Anamnesi Fisiologica
    var physiologicalAnamnesisSection: some View {
        Section {
            ToggleGroupView(
                title: "È nato da parto naturale?",
                options: ["NO", "SI", "Altro"],
                selectedOption: $partoNaturale
            )
            if partoNaturale == "Altro" {
                TextField("Specifica", text: $partoNaturale)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            ToggleGroupView(
                title: "Vaccinazioni",
                options: ["NON LO SO", "NO", "SI"],
                selectedOption: $vaccinazioni
            )
            
            VStack(alignment: .leading, spacing: 15) {
                Toggle(isOn: $assumeFarmaci) {
                    Text("Assume regolarmente farmaci e/o integratori alimentari?")
                }
                
                if assumeFarmaci {
                    TextField("Se sì, quali?", text: $qualiFarmaci)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
            }
            .padding(.vertical)
            
            VStack(alignment: .leading, spacing: 15) {
                Toggle(isOn: $esamiSangue) {
                    Text("Ha eseguito esami del sangue nell'ultimo anno?")
                }
                
                if esamiSangue {
                    TextField("Se si, erano presenti alterazioni?", text: $alterazioniEsamiSangue)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
            }
            .padding(.vertical)
            
            VStack(alignment: .leading) {
                Text("Dieta")
                
                HStack {
                    CheckboxField(title: "Varia", isChecked: Binding(get: { dieta == "Varia" }, set: { if $0 { dieta = "Varia" } }), checkboxOnRight: false)
                    Spacer()
                    CheckboxField(title: "Vegana", isChecked: Binding(get: { dieta == "Vegana" }, set: { if $0 { dieta = "Vegana" } }), checkboxOnRight: true)
                }
                
                HStack {
                    CheckboxField(title: "Vegetariana", isChecked: Binding(get: { dieta == "Vegetariana" }, set: { if $0 { dieta = "Vegetariana" } }), checkboxOnRight: false)
                    Spacer()
                    CheckboxField(title: "Speciale", isChecked: Binding(get: { dieta == "Speciale" }, set: { if $0 { dieta = "Speciale" } }), checkboxOnRight: true)
                }
            }
            
            if dieta == "Speciale" {
                TextField("Specifica dieta speciale", text: $dietaSpeciale)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            ToggleGroupView(
                title: "Fumatore?",
                options: ["NO", "SI", "EX"],
                selectedOption: $fumo
            )
            if fumo == "SI" {
                TextField("Quante sigarette al giorno e da quanto tempo?", text: $quanteSigarette)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            VStack(alignment: .leading, spacing: 15) {
                Toggle(isOn: $beveAlcolici) {
                    Text("Beve alcolici?")
                }
                if beveAlcolici {
                    TextField("Quantità di alcol consumata", text: $consumoAlcol)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
            }
            .padding(.vertical)
            
            VStack(alignment: .leading, spacing: 15) {
                Toggle(isOn: $beveCaffe) {
                    Text("Beve caffè/the/coca-cola")
                }
                if beveCaffe {
                    TextField("Quantità di caffè/the/coca-cola consumata", text: $consumoCaffe)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
            }
            .padding(.vertical)
            
            if viewModel.gender == "Femminile" {
                HStack {
                    Text("Età prima mestruazione")
                    Spacer()
                    TextField("Anni", text: Binding(
                        get: { "\(etaMestruazione)" },
                        set: {
                            if let value = Decimal(string: $0) {
                                etaMestruazione = value
                            } else {
                                etaMestruazione = 0
                            }
                        }
                    ))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.decimalPad)
                }
                
                HStack {
                    Text("Data ultima mestruazione")
                    DatePicker("", selection: $dataUltimaMestruazione, displayedComponents: .date)
                        .datePickerStyle(CompactDatePickerStyle())
                }
                
                Toggle("Anomalie del ciclo mestruale", isOn: $anomalieCiclo)
                if anomalieCiclo {
                    TextField("Note sulle anomalie", text: $noteAnomalieCiclo)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                Toggle("Gravidanze", isOn: $gravidanze)
            } else {
                // Non mostrare
            }
        }
    }
    
    // Pulsante di Salvataggio
    var saveButton: some View {
        Button(action: {
            UIApplication.shared.endEditing()
            viewModel.savePatient()
            showSuccessMessage = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                withAnimation {
                    showSuccessMessage = false
                }
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
    
    // Overlay per il messaggio di successo
    var successOverlay: some View {
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
        .cornerRadius(20)
        .shadow(radius: 20)
        .transition(.opacity)
        .zIndex(1)
    }
}

// Componenti di Supporto

struct ToggleGroupView: View {
    let title: String
    let options: [String]
    @Binding var selectedOption: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
            HStack {
                ForEach(options, id: \.self) { option in
                    Button(action: {
                        selectedOption = option
                    }) {
                        HStack {
                            Text(option)
                            Image(systemName: selectedOption == option ? "checkmark.circle.fill" : "circle")
                        }
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    .foregroundColor(.blue)
                }
            }
        }
    }
}

struct CheckboxField: View {
    let title: String
    @Binding var isChecked: Bool
    let checkboxOnRight: Bool
    
    var body: some View {
        Button(action: {
            isChecked.toggle()
        }) {
            HStack {
                if checkboxOnRight {
                    Text(title)
                    Image(systemName: isChecked ? "checkmark.square.fill" : "square")
                } else {
                    Image(systemName: isChecked ? "checkmark.square.fill" : "square")
                    Text(title)
                }
            }
            .foregroundColor(.blue)
        }
        .buttonStyle(BorderlessButtonStyle())
    }
}
