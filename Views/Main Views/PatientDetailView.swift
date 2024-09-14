import SwiftUI
import CoreData
import UniformTypeIdentifiers
import PDFKit

struct PatientDetailView: View {
    @ObservedObject var viewModel: PatientViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var showingDocumentPicker = false
    @State private var showingPDF = false
    @State private var scelta: String? = nil
    
    let context: NSManagedObjectContext
    
    // Crea un DateFormatter
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long // Puoi modificare lo stile della data come preferisci
        return formatter
    }()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // Sezione Anagrafica
                SectionCard(header: "Anagrafica") {
                    VStack {
                        HStack {
                            Text("Nome Completo:")
                                .font(.headline)
                            Spacer()
                            Text("\(viewModel.patient.name ?? "N/A") \(viewModel.patient.surname ?? "N/A")")
                                .font(.body)
                        }
                        Divider()
                        
                        HStack {
                            Text("Data di Nascita:")
                                .font(.headline)
                            Spacer()
                            Text(viewModel.patient.birthDate != nil ? dateFormatter.string(from: viewModel.patient.birthDate!) : "N/A")
                                .font(.body)
                        }
                        
                        DetailRow(title: "Indirizzo di Residenza:", value: viewModel.patient.residenceAddress ?? "N/A")
                        DetailRow(title: "Codice Fiscale:", value: viewModel.patient.cf ?? "N/A")
                        DetailRow(title: "Sesso:", value: viewModel.patient.gender ?? "N/A")
                        DetailRow(title: "Telefono:", value: viewModel.patient.tel ?? "N/A")
                    }
                }
                
                // Sezione Anamnesi Sportiva
                SectionCard(header: "Anamnesi Sportiva") {
                    VStack {
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
                }
                
                // Sezione Condizioni Mediche
                SectionCard(header: "Condizioni Mediche") {
                    VStack {
                        if !anyMedicalConditionPresent() {
                            // Mostra messaggio se nessuna condizione è presente
                            Text("Nessuna condizione medica presente")
                                .font(.body)
                                .foregroundColor(.gray)
                        } else {
                            if viewModel.patient.diabetesMellitus {
                                MedicalConditionRow(condition: "Diabete Mellito", isPresent: true)
                            }
                            if viewModel.patient.heartDisease {
                                MedicalConditionRow(condition: "Malattie di Cuore", isPresent: true)
                            }
                            if viewModel.patient.thyroidDiseases {
                                MedicalConditionRow(condition: "Malattie Tiroidee", isPresent: true)
                            }
                            if viewModel.patient.suddenDeath {
                                MedicalConditionRow(condition: "Morte Improvvisa in Famiglia", isPresent: true)
                            }
                            if viewModel.patient.pulmonaryDiseases {
                                MedicalConditionRow(condition: "Malattie Polmonari", isPresent: true)
                            }
                            if viewModel.patient.myocardialInfarction {
                                MedicalConditionRow(condition: "Infarto del Miocardio", isPresent: true)
                            }
                            if viewModel.patient.cardiomyopathies {
                                MedicalConditionRow(condition: "Cardiomiopatie", isPresent: true)
                            }
                            if viewModel.patient.hypertension {
                                MedicalConditionRow(condition: "Ipertensione", isPresent: true)
                            }
                            if viewModel.patient.highCholesterol {
                                MedicalConditionRow(condition: "Colesterolo Alto", isPresent: true)
                            }
                            if viewModel.patient.celiacDisease {
                                MedicalConditionRow(condition: "Celiachia", isPresent: true)
                            }
                            if viewModel.patient.strokeNeurological {
                                MedicalConditionRow(condition: "Ictus/Malattie Neurologiche", isPresent: true)
                            }
                            if viewModel.patient.tumors {
                                MedicalConditionRow(condition: "Tumori", isPresent: true)
                            }
                            if viewModel.patient.asthmaAllergies {
                                MedicalConditionRow(condition: "Asma/Allergie", isPresent: true)
                            }
                            if viewModel.patient.obesity {
                                MedicalConditionRow(condition: "Obesità", isPresent: true)
                            }
                            if viewModel.patient.geneticDiseases {
                                MedicalConditionRow(condition: "Malattie Genetiche", isPresent: true)
                            }
                        }
                    }
                }
                
                // Sezione Anamnesi Fisiologica
                SectionCard(header: "Anamnesi Fisiologica") {
                    VStack {
                        DetailRow(title: "Parto Naturale:", value: viewModel.patient.partoNaturale ?? "N/A")
                        DetailRow(title: "Vaccinazioni:", value: viewModel.patient.vaccinazioni ?? "N/A")
                        DetailRow(title: "Dieta:", value: viewModel.patient.dieta ?? "N/A")
                        
                        if let quanteSigarette = viewModel.patient.quanteSigarette, !quanteSigarette.isEmpty {
                            DetailRow(title: "Fumatore:", value: "Sì")
                            DetailRow(title: "Quante Sigarette:", value: quanteSigarette)
                        } else {
                            DetailRow(title: "Fumatore:", value: viewModel.patient.fumo ?? "N/A")
                        }
                        
                        if viewModel.patient.consumoAlcol == "NO" {
                            DetailRow(title: "Beve alcolici?", value: "NO")
                        } else {
                            DetailRow(title: "Beve alcolici?", value: "Sì")
                            if let consumoAlcol = viewModel.patient.consumoAlcol {
                                DetailRow(title: "Quanto?", value: consumoAlcol)
                            }
                        }
                        
                        DetailRow(title: "Consumo di Caffè:", value: viewModel.patient.consumoCaffe ?? "N/A")
                        if let etaMestruazione = viewModel.patient.etaMestruazione {
                            DetailRow(title: "Età Prima Mestruazione:", value: "\(etaMestruazione)")
                        }
                        DetailRow(title: "Anomalie Ciclo:", value: viewModel.patient.noteAnomalieCiclo ?? "N/A")
                        DetailRow(title: "Gravidanze:", value: viewModel.patient.gravidanze ? "Sì" : "No")
                        if let qualiFarmaci = viewModel.patient.qualiFarmaci, !qualiFarmaci.isEmpty {
                            DetailRow(title: "Farmaci Assunti:", value: qualiFarmaci)
                        }
                        if let alterazioniEsamiSangue = viewModel.patient.alterazioniEsamiSangue, !alterazioniEsamiSangue.isEmpty {
                            DetailRow(title: "Alterazioni Esami del Sangue:", value: alterazioniEsamiSangue)
                        }
                    }
                }
                
                // Sezione PDF
                SectionCard(header: "Carica E.C.G.") {
                    VStack {
                        if let pdfFileURL = viewModel.pdfFileURL {
                            Button(action: {
                                showingPDF = true
                            }) {
                                Text("Visualizza")
                                    .font(.headline)
                                    .foregroundColor(.blue)
                            }
                            .sheet(isPresented: $showingPDF) {
                                PDFViewer(pdfURL: pdfFileURL)
                            }
                            Button(action: {
                                viewModel.removePDF()
                            }) {
                                Text("Rimuovi")
                                    .font(.headline)
                                    .foregroundColor(.red)
                            }
                        } else {
                            Button(action: {
                                showingDocumentPicker = true
                            }) {
                                Text("Aggiungi")
                                    .font(.headline)
                                    .foregroundColor(.blue)
                            }
                            .fileImporter(isPresented: $showingDocumentPicker, allowedContentTypes: [.pdf]) { result in
                                switch result {
                                case .success(let url):
                                    viewModel.savePDF(url: url)
                                case .failure(let error):
                                    print("Errore durante l'importazione del file: \(error.localizedDescription)")
                                }
                            }
                        }
                    }
                }
                
                // Sezione Nota
                SectionCard(header: "Nota") {
                    VStack {
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
                            viewModel.saveNote()
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
                
            }
            .padding()
        }
        .navigationBarTitle("Dettagli Paziente", displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        //.navigationBarItems(leading: backButton)
    }
    
    
    
    // Funzione per verificare se almeno una condizione medica è presente
    private func anyMedicalConditionPresent() -> Bool {
        return viewModel.patient.diabetesMellitus ||
        viewModel.patient.heartDisease ||
        viewModel.patient.thyroidDiseases ||
        viewModel.patient.suddenDeath ||
        viewModel.patient.pulmonaryDiseases ||
        viewModel.patient.myocardialInfarction ||
        viewModel.patient.cardiomyopathies ||
        viewModel.patient.hypertension ||
        viewModel.patient.highCholesterol ||
        viewModel.patient.celiacDisease ||
        viewModel.patient.strokeNeurological ||
        viewModel.patient.tumors ||
        viewModel.patient.asthmaAllergies ||
        viewModel.patient.obesity ||
        viewModel.patient.geneticDiseases
    }
    
    // Viewer per mostrare il PDF
    struct PDFViewer: View {
        let pdfURL: URL
        
        var body: some View {
            PDFKitRepresentedView(url: pdfURL)
                .edgesIgnoringSafeArea(.all)
        }
    }
}
