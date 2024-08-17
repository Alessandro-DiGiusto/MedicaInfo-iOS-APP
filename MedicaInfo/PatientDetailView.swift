import SwiftUI
import CoreData

struct PatientDetailView: View {
    @ObservedObject var viewModel: PatientViewModel
    let dateFormatter: DateFormatter

    init(patient: Patient, dateFormatter: DateFormatter) {
        self.viewModel = PatientViewModel(patient: patient)
        self.dateFormatter = dateFormatter
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Sezione Anagrafica
                SectionCard(header: "Anagrafica") {
                    HStack {
                        Text("Nome Completo:")
                            .font(.headline)
                        Spacer()
                        Text("\(viewModel.patient.name ?? "N/A") \(viewModel.patient.surname ?? "N/A")")
                            .font(.body)
                    }
                    Divider()
                    DetailRow(title: "Data di Nascita:", value: dateFormatter.string(from: viewModel.patient.birthDate ?? Date()))

                    // Picker per Comune di Nascita
                    Picker("Comune di Nascita", selection: $viewModel.selectedComuneNascita) {
                        ForEach(viewModel.comuni) { comune in
                            Text(comune.nome).tag(comune as Comune?)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())

                    // Campo separato per l'indirizzo di residenza
                    DetailRow(title: "Indirizzo di Residenza:", value: viewModel.patient.residenceAddress ?? "N/A")
                    DetailRow(title: "Codice Fiscale:", value: viewModel.patient.cf ?? "N/A")
                    DetailRow(title: "Sesso:", value: viewModel.patient.gender ?? "N/A")
                    DetailRow(title: "Telefono:", value: viewModel.patient.tel ?? "N/A")
                }
                
                // Sezione Anamnesi Sportiva
                SectionCard(header: "Anamnesi Sportiva") {
                    DetailRow(title: "Sport Richiesto:", value: viewModel.patient.requiredSport ?? "N/A")
                    if viewModel.patient.yearsOfPractice > 0 {
                        DetailRow(title: "Anni di Pratica:", value: "\(viewModel.patient.yearsOfPractice)")
                    }
                    if viewModel.patient.weeklyHours > 0 {
                        DetailRow(title: "Ore Settimanali:", value: "\(viewModel.patient.weeklyHours)")
                    }
                    DetailRow(title: "Pratica Altri Sport:", value: viewModel.patient.practicesOtherSports ? "Sì" : "No")
                    if viewModel.patient.practicesOtherSports {
                        DetailRow(title: "Altri Sport:", value: viewModel.patient.otherSportsDetails ?? "N/A")
                    }
                    DetailRow(title: "Sport Praticati in Passato:", value: viewModel.patient.pastSports ?? "N/A")
                }
                
                // Sezione Condizioni Mediche
                SectionCard(header: "Condizioni Mediche") {
                    MedicalConditionRow(condition: "Diabete Mellito", isPresent: viewModel.patient.diabetesMellitus)
                    MedicalConditionRow(condition: "Malattie di Cuore", isPresent: viewModel.patient.heartDisease)
                    MedicalConditionRow(condition: "Malattie Tiroidee", isPresent: viewModel.patient.thyroidDiseases)
                    MedicalConditionRow(condition: "Morte Improvvisa in Famiglia", isPresent: viewModel.patient.suddenDeath)
                    MedicalConditionRow(condition: "Malattie Polmonari", isPresent: viewModel.patient.pulmonaryDiseases)
                    MedicalConditionRow(condition: "Infarto del Miocardio", isPresent: viewModel.patient.myocardialInfarction)
                    MedicalConditionRow(condition: "Cardiomiopatie", isPresent: viewModel.patient.cardiomyopathies)
                    MedicalConditionRow(condition: "Ipertensione", isPresent: viewModel.patient.hypertension)
                    MedicalConditionRow(condition: "Colesterolo Alto", isPresent: viewModel.patient.highCholesterol)
                    MedicalConditionRow(condition: "Celiachia", isPresent: viewModel.patient.celiacDisease)
                    MedicalConditionRow(condition: "Ictus/Malattie Neurologiche", isPresent: viewModel.patient.strokeNeurological)
                    MedicalConditionRow(condition: "Tumori", isPresent: viewModel.patient.tumors)
                    MedicalConditionRow(condition: "Asma/Allergie", isPresent: viewModel.patient.asthmaAllergies)
                    MedicalConditionRow(condition: "Obesità", isPresent: viewModel.patient.obesity)
                    MedicalConditionRow(condition: "Malattie Genetiche", isPresent: viewModel.patient.geneticDiseases)
                }
                
                // Sezione Nota
                SectionCard(header: "Nota") {
                    Text(viewModel.patient.nota ?? "Nessuna nota inserita")
                        .font(.body)
                        .padding(.vertical, 10)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    
                    // Campo di testo per aggiungere una nota
                    TextField("Aggiungi una nota", text: $viewModel.noteText)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    
                    // Pulsante per salvare la nota
                    Button(action: {
                        viewModel.updateNoteText()
                    }) {
                        Text("Salva Nota")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding(.top, 10)
                }
            }
            .padding()
            .navigationBarTitle("Dettagli Paziente", displayMode: .inline)
        }
    }
    
    // MARK: - UI Components
    
    // Card per ogni sezione
    struct SectionCard<Content: View>: View {
        let header: String
        let content: Content
        
        init(header: String, @ViewBuilder content: () -> Content) {
            self.header = header
            self.content = content()
        }
        
        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text(header)
                    .font(.title2)
                    .bold()
                    .padding(.bottom, 5)
                content
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
    }
    
    // Riga di dettaglio per informazioni di base
    struct DetailRow: View {
        let title: String
        let value: String
        
        var body: some View {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Spacer()
                Text(value)
                    .font(.body)
                    .foregroundColor(.primary)
            }
            .padding(.vertical, 4)
        }
    }
    
    // Riga per le condizioni mediche
    struct MedicalConditionRow: View {
        let condition: String
        let isPresent: Bool
        
        var body: some View {
            if isPresent {
                HStack {
                    Text("⚠️ \(condition)")
                        .font(.body)
                        .foregroundColor(.red)
                    Spacer()
                }
                .padding(.vertical, 4)
            }
        }
    }
}
