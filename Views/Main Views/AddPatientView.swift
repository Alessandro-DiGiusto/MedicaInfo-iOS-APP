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
    @State private var partoNaturaleSelection: String = ""
    @State private var altroInput: String = ""
    @State private var vaccinazioni: String = ""
    @State private var assumeFarmaci: Bool = false
    @State private var qualiFarmaci: String = ""
    @State private var esamiSangue: Bool = false
    @State private var sceltaDieta: String = ""
    @State private var sceltaFumatore: String = ""
    @State private var sceltaAlcolistica: String = ""
    @State private var consumoAlcol: String = ""
    @State private var sceltaCaffe: String = ""
    @State private var consumoCaffe: String = ""
    
    //DATA PICKER DATA DI NASCITA
    // Stato per tenere traccia della data di nascita selezionata
    @State private var birthDate = Date()
    
    // Inizializzazione del ViewModel
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
                    parto
                    caffe
                    vax
                    farmaci
                    esami
                    alimentazione
                    fumiamola
                    alcolista
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
                    // Aggiungi il DatePicker per la selezione della data
                    Image(systemName: "calendar").foregroundColor(.blue)
                    DatePicker("Data di nascita", selection: $viewModel.birthDate, displayedComponents: [.date])
                        .datePickerStyle(.automatic) // Puoi scegliere lo stile che preferisci
                        .labelsHidden()
                        .accentColor(.blue)
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
                //TextField("barrare le caselle in caso di parente affetto (padre, madre, fratelli, sorelle, nonni paterni/matemi) e specificare il parente che soffra o abbia sofferto di:")
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
    var parto: some View {
        Section(header: Text("ANAMNESI FISIOLOGICA")
            .font(.headline)
            .foregroundColor(.blue)) {
                ToggleGroupView(
                    title: "È nato da parto naturale?",
                    options: ["NO", "SI", "Altro"],
                    selectedOption: $partoNaturaleSelection
                )
                if partoNaturaleSelection == "Altro" {
                    TextField("Specifica", text: $altroInput)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onChange(of: altroInput) { newValue in
                            viewModel.partoNaturale = newValue
                        }
                }
            }
            .onChange(of: partoNaturaleSelection) { newValue in
                if newValue != "Altro" {
                    viewModel.partoNaturale = newValue
                }
            }
    }
    
    var caffe: some View {
        Section(header: Text("")
            .font(.headline)
            .foregroundColor(.blue)) {
                
                ToggleGroupView(
                    title: "Consuma Caffè",
                    options: ["NO", "SI"],
                    selectedOption: $sceltaCaffe
                )
                
                if sceltaCaffe == "SI" {
                    TextField("Quanti caffè prende al giorno?", text: $consumoCaffe)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onChange(of: consumoCaffe) { newValue in
                            viewModel.consumoCaffe = newValue
                        }
                }
            }
            .onChange(of: sceltaCaffe) { newValue in
                if newValue == "NO" {
                    viewModel.consumoCaffe = "NO"
                } else if newValue == "SI" && !consumoCaffe.isEmpty {
                    viewModel.consumoCaffe = consumoCaffe
                }
            }
    }
    
    var vax: some View {
        Section(){
            ToggleGroupView(
                title: "Vaccinazioni",
                options: ["NON LO SO", "NO", "SI"],
                selectedOption: $viewModel.vaccinazioni
            )
        }
    }
    
    var farmaci: some View {
        
        VStack(alignment: .leading, spacing: 15) {
            Toggle(isOn: $assumeFarmaci) {
                Text("Assume regolarmente farmaci e/o integratori alimentari?")
            }
            
            if assumeFarmaci {
                TextField("Se sì, quali?", text: $viewModel.qualiFarmaci)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
        }
        .padding(.vertical)
        
    }
    
    var esami: some View {
        VStack(alignment: .leading, spacing: 15) {
            Toggle(isOn: $esamiSangue) {
                Text("Ha eseguito esami del sangue nell'ultimo anno?")
            }
            
            if esamiSangue {
                TextField("Se si, erano presenti alterazioni?", text: $viewModel.alterazioniEsamiSangue)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
        }
        .padding(.vertical)
    }
    
    var alimentazione: some View {
        VStack(alignment: .leading) {
            Text("Dieta")
            
            HStack {
                DietaButton(title: "Varia", selectedOption: $viewModel.dieta, optionValue: "Varia")
                Spacer()
                DietaButton(title: "Vegana", selectedOption: $viewModel.dieta, optionValue: "Vegana")
            }
            
            HStack {
                DietaButton(title: "Vegetariana", selectedOption: $viewModel.dieta, optionValue: "Vegetariana")
                Spacer()
                DietaButton(title: "Speciale", selectedOption: $sceltaDieta, optionValue: "Speciale")
            }
            
            if sceltaDieta == "Speciale" {
                TextField("Specifica dieta speciale", text: Binding(
                    get: { viewModel.dieta.replacingOccurrences(of: "Speciale: ", with: "") },
                    set: { newValue in
                        viewModel.dieta = "Speciale: \(newValue)"
                    }
                ))
                .textFieldStyle(RoundedBorderTextFieldStyle())
            }
        }
        .padding(.vertical)
    }
    
    var fumiamola: some View {
        VStack(alignment: .leading) {
            Text("Fumatore?")
            
            HStack {
                DietaButton(title: "NO", selectedOption: $viewModel.fumo, optionValue: "NO")
                Spacer()
                DietaButton(title: "EX", selectedOption: $viewModel.fumo, optionValue: "EX")
                Spacer()
                DietaButton(title: "SI", selectedOption: $viewModel.fumo, optionValue: "SI")
            }
            
            if sceltaFumatore == "SI" {
                TextField("Quante sigarette al giorno fumi?", text: Binding(
                    get: { viewModel.quanteSigarette.replacingOccurrences(of: "Si: ", with: "") },
                    set: { newValue in
                        viewModel.quanteSigarette = " \(newValue)"
                    }
                ))
                .textFieldStyle(RoundedBorderTextFieldStyle())
            }
        }
        .padding(.vertical)
    }
    
    var alcolista: some View {
        VStack(alignment: .leading) {
            Text("Beve alcolici?")
            
            HStack {
                DietaButton(title: "NO", selectedOption: $sceltaAlcolistica, optionValue: "NO")
                    .onTapGesture {
                        sceltaAlcolistica = "NO"
                        viewModel.consumoAlcol = "NO" // Salva "NO" in consumoAlcol
                    }
                Spacer()
                DietaButton(title: "SI", selectedOption: $sceltaAlcolistica, optionValue: "SI")
                    .onTapGesture {
                        sceltaAlcolistica = "SI"
                        viewModel.consumoAlcol = "" // Pulisci il campo per permettere l'input
                    }
            }
            
            if sceltaAlcolistica == "SI" {
                TextField("Quanti?", text: $viewModel.consumoAlcol)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
        }
        .padding(.vertical)
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
