//
//  PatientDetailView.swift
//  MedicaInfo
//
//  Created by Alessandro Di Giusto on 02/06/24.
//

import SwiftUI
import CoreData
import UniformTypeIdentifiers

struct PatientDetailView: View {
    @ObservedObject var viewModel: PatientViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var showingDocumentPicker = false
    @State private var showingPDF = false

    let context: NSManagedObjectContext

    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    init(patient: Patient, context: NSManagedObjectContext) {
        self.viewModel = PatientViewModel(patient: patient, context: context)
        self.context = context
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Sezione Anagrafica
                SectionCard(header: "Anagrafica") {
                    DetailRow(title: "Nome Completo:", value: "\(viewModel.patient.name ?? "N/A") \(viewModel.patient.surname ?? "N/A")")
                    DetailRow(title: "Data di Nascita:", value: viewModel.patient.birthDate != nil ? dateFormatter.string(from: viewModel.patient.birthDate!) : "N/A")
                    DetailRow(title: "Indirizzo di Residenza:", value: viewModel.patient.residenceAddress ?? "N/A")
                    DetailRow(title: "Codice Fiscale:", value: viewModel.patient.cf ?? "N/A")
                    DetailRow(title: "Sesso:", value: viewModel.patient.gender ?? "N/A")
                    DetailRow(title: "Luogo di Nascita:", value: viewModel.patient.birthPlace ?? "N/A")
                    DetailRow(title: "Telefono:", value: viewModel.patient.tel ?? "N/A")
                }

                // Sezione Anamnesi Sportiva
                SectionCard(header: "Anamnesi Sportiva") {
                    DetailRow(title: "Sport Richiesto:", value: viewModel.patient.requiredSport ?? "N/A")
                    DetailRow(title: "Anni di Pratica:", value: "\(viewModel.patient.yearsOfPractice)")
                    DetailRow(title: "Ore Settimanali:", value: "\(viewModel.patient.weeklyHours)")
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

                // Sezione Stile di Vita
                SectionCard(header: "Stile di Vita") {
                    DetailRow(title: "Parto Naturale:", value: viewModel.patient.partoNaturale ?? "N/A")
                    DetailRow(title: "Vaccinazioni:", value: viewModel.patient.vaccinazioni ?? "N/A")
                    DetailRow(title: "Dieta:", value: viewModel.patient.dieta ?? "N/A")
                    DetailRow(title: "Fumo:", value: viewModel.patient.fumo  ?? "N/A")
                    DetailRow(title: "Quante Sigarette:", value: viewModel.patient.quanteSigarette != nil ? String(viewModel.patient.quanteSigarette!) : "N/A")
                    DetailRow(title: "Consumo di Alcol:", value: viewModel.patient.consumoAlcol ?? "N/A")
                    DetailRow(title: "Consumo di Caffè:", value: viewModel.patient.consumoCaffe ?? "N/A")
                }

                // Sezione Mestruazioni e Gravidanze
                if let etaMestruazione = viewModel.patient.etaMestruazione?.intValue {
                    SectionCard(header: "Mestruazioni e Gravidanze") {
                        DetailRow(title: "Età Mestruazione:", value: "\(etaMestruazione)")
                        DetailRow(title: "Anomalie del Ciclo:", value: viewModel.patient.noteAnomalieCiclo ?? "N/A")
                        DetailRow(title: "Gravidanze:", value: viewModel.patient.gravidanze ? "Sì" : "No")
                    }
                }

                // Sezione Farmaci e Esami del Sangue
                SectionCard(header: "Farmaci e Esami del Sangue") {
                    DetailRow(title: "Quali Farmaci:", value: viewModel.patient.qualiFarmaci ?? "N/A")
                    DetailRow(title: "Alterazioni Esami del Sangue:", value: viewModel.patient.alterazioniEsamiSangue ?? "N/A")
                }

                // Sezione PDF
                SectionCard(header: "Carica E.C.G.") {
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
                                print("Errore durante l'importazione del file, \n ricorda che deve essere in formato PDF: \(error.localizedDescription)")
                            }
                        }
                    }
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
            .padding()
        }
        .navigationBarTitle("Dettagli Paziente", displayMode: .inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButton)
    }

    // Pulsante indietro personalizzato
    var backButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "chevron.left")
                .foregroundColor(.blue)
            Text("Indietro")
                .foregroundColor(.blue)
        }
    }
}

// Viewer per mostrare il PDF
struct PDFViewer: View {
    let pdfURL: URL

    var body: some View {
        PDFKitRepresentedView(url: pdfURL)
            .edgesIgnoringSafeArea(.all)
    }
}
