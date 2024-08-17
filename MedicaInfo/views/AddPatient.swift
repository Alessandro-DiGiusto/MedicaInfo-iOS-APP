import SwiftUI
import CoreData

struct AddPatientView: View {
    @Environment(\.managedObjectContext) private var context
    @StateObject private var viewModel: AddPatientViewModel

    
    init() {
        _viewModel = StateObject(wrappedValue: AddPatientViewModel(context: PersistenceController.shared.container.viewContext))
    }
    
    private let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        return formatter
    }()
    
    var body: some View {
        Form {
            Section(header: Text("Dati Personali")) {
                TextField("Nome", text: $viewModel.name)
                TextField("Cognome", text: $viewModel.surname)
                DatePicker("Data di Nascita", selection: $viewModel.birthDate, displayedComponents: .date)
                TextField("Codice Fiscale", text: $viewModel.cf)
                
                Picker("Sesso", selection: $viewModel.gender) {
                    Text("Maschile").tag("Maschile")
                    Text("Femminile").tag("Femminile")
                }
                .pickerStyle(SegmentedPickerStyle())

                Picker("Luogo di Nascita", selection: $viewModel.selectedComuneNascita) {
                    ForEach(viewModel.comuni) { comune in
                        Text(comune.nome).tag(comune as Comune?)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .onChange(of: viewModel.selectedComuneNascita) { selectedComune in
                    viewModel.birthPlace = selectedComune?.nome ?? ""
                }

                TextField("Indirizzo di Residenza", text: $viewModel.residenceAddress)
                TextField("Telefono", text: $viewModel.tel)
            }
            
            Section(header: Text("Anamnesi Sportiva")) {
                Toggle("Anamnesi Sportiva", isOn: $viewModel.sportAnamnesis)
                if viewModel.sportAnamnesis {
                    TextField("Sport per il quale è richiesta la visita:", text: $viewModel.requiredSport)
                    
                    Text("Da quanti anni pratica questo sport?")
                    TextField("Anni di pratica", value: Binding(
                        get: { viewModel.yearsOfPractice ?? 0 },
                        set: { viewModel.yearsOfPractice = $0 == 0 ? nil : $0 }
                    ), formatter: numberFormatter)
                    .keyboardType(.numberPad)
                    
                    Text("Quante ore dedica alla settimana?")
                    TextField("Ore settimanali", value: Binding(
                        get: { viewModel.weeklyHours ?? 0 },
                        set: { viewModel.weeklyHours = $0 == 0 ? nil : $0 }
                    ), formatter: numberFormatter)
                    .keyboardType(.numberPad)
                    
                    Toggle("Pratica altri sport", isOn: $viewModel.practicesOtherSports)
                    if viewModel.practicesOtherSports {
                        TextField("Dettagli su altri sport", text: $viewModel.otherSportsDetails)
                    }
                    TextField("Sport praticati in passato", text: $viewModel.pastSports)
                }
            }
            
            Section(header: Text("Condizioni Mediche")) {
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
            
            Button(action: {
                viewModel.savePatient()
            }) {
                Text("Salva")
                    .fontWeight(.bold)
            }
        }
        .navigationTitle("Aggiungi Paziente")
        .onAppear {
            // Carica i comuni se non sono stati già caricati
            if viewModel.comuni.isEmpty {
                viewModel.loadComuni()
            }
        }
    }
}
