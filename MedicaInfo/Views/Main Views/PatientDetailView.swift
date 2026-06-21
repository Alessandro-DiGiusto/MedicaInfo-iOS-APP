import SwiftUI
import CoreData
import UniformTypeIdentifiers

// MARK: - PatientDetailView — Professional Medical Record 2026
struct PatientDetailView: View {
    @ObservedObject var viewModel: PatientViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingDocumentPicker = false
    @State private var showingPDF = false

    let context: NSManagedObjectContext

    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .long
        f.locale = Locale(identifier: "it_IT")
        return f
    }()

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                anagraficaCard
                sportCard
                medicalConditionsCard
                physiologicalCard
                pdfCard
                noteCard
                Color.clear.frame(height: 20)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
        #if os(iOS)
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        #else
        .background(Color(.controlBackgroundColor))
        #endif
        .navigationTitle("Dettagli Paziente")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }

    // MARK: - Anagrafica
    private var anagraficaCard: some View {
        FormCard(icon: "person.text.rectangle", title: "Anagrafica", color: .blue) {
            DetailRowView(label: "Nome Completo", value: "\(viewModel.patient.name ?? "") \(viewModel.patient.surname ?? "")")
            DetailRowView(label: "Data di Nascita", value: viewModel.patient.birthDate.map { dateFormatter.string(from: $0) } ?? "N/A")
            DetailRowView(label: "Codice Fiscale", value: viewModel.patient.cf ?? "N/A")
            DetailRowView(label: "Sesso", value: viewModel.patient.gender ?? "N/A")
            DetailRowView(label: "Residenza", value: viewModel.patient.residenceAddress ?? "N/A")
            DetailRowView(label: "Telefono", value: viewModel.patient.tel ?? "N/A")
        }
    }

    // MARK: - Anamnesi Sportiva
    private var sportCard: some View {
        FormCard(icon: "sportscourt", title: "Anamnesi Sportiva", color: .orange) {
            if !hasSportData {
                Text("Nessuna informazione sportiva")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                if let sport = viewModel.patient.requiredSport, !sport.isEmpty {
                    DetailRowView(label: "Sport Richiesto", value: sport)
                }
                if viewModel.patient.yearsOfPractice > 0 {
                    DetailRowView(label: "Anni di Pratica", value: "\(viewModel.patient.yearsOfPractice)")
                }
                if viewModel.patient.weeklyHours > 0 {
                    DetailRowView(label: "Ore Settimanali", value: "\(viewModel.patient.weeklyHours)")
                }
                DetailRowView(label: "Altri Sport", value: viewModel.patient.practicesOtherSports ? (viewModel.patient.otherSportsDetails ?? "Sì") : "No")
                DetailRowView(label: "Sport Passati", value: viewModel.patient.pastSports ?? "N/A")
            }
        }
    }

    private var hasSportData: Bool {
        !(viewModel.patient.requiredSport ?? "").isEmpty
        || viewModel.patient.yearsOfPractice > 0
        || viewModel.patient.weeklyHours > 0
        || viewModel.patient.practicesOtherSports
        || !(viewModel.patient.pastSports ?? "").isEmpty
    }

    // MARK: - Condizioni Mediche
    private var medicalConditionsCard: some View {
        FormCard(icon: "heart.text.square", title: "Condizioni Mediche", color: .red) {
            let conditions = activeConditions
            if conditions.isEmpty {
                Text("Nessuna condizione medica")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 6) {
                    ForEach(conditions, id: \.self) { condition in
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundColor(.red)
                            Text(condition)
                                .font(.caption)
                                .foregroundColor(.primary)
                            Spacer()
                        }
                        .padding(8)
                        .background(Color.red.opacity(0.06))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
        }
    }

    private var activeConditions: [String] {
        var result: [String] = []
        if viewModel.patient.diabetesMellitus { result.append("Diabete Mellito") }
        if viewModel.patient.heartDisease { result.append("Malattie Cuore") }
        if viewModel.patient.thyroidDiseases { result.append("Malattie Tiroidee") }
        if viewModel.patient.suddenDeath { result.append("Morte Improvvisa") }
        if viewModel.patient.pulmonaryDiseases { result.append("Mal. Polmonari") }
        if viewModel.patient.myocardialInfarction { result.append("Infarto Miocardio") }
        if viewModel.patient.cardiomyopathies { result.append("Cardiomiopatie") }
        if viewModel.patient.hypertension { result.append("Ipertensione") }
        if viewModel.patient.highCholesterol { result.append("Colesterolo Alto") }
        if viewModel.patient.celiacDisease { result.append("Celiachia") }
        if viewModel.patient.strokeNeurological { result.append("Ictus/Neurologiche") }
        if viewModel.patient.tumors { result.append("Tumori") }
        if viewModel.patient.asthmaAllergies { result.append("Asma/Allergie") }
        if viewModel.patient.obesity { result.append("Obesità") }
        if viewModel.patient.geneticDiseases { result.append("Mal. Genetiche") }
        return result
    }

    // MARK: - Anamnesi Fisiologica
    private var physiologicalCard: some View {
        FormCard(icon: "person.crop.rectangle.stack", title: "Anamnesi Fisiologica", color: .teal) {
            VStack(spacing: 4) {
                PhysiologicalDetail(label: "Parto Naturale", value: viewModel.patient.partoNaturale)
                PhysiologicalDetail(label: "Vaccinazioni", value: viewModel.patient.vaccinazioni)
                PhysiologicalDetail(label: "Dieta", value: viewModel.patient.dieta)
                PhysiologicalDetail(label: "Fumo", value: viewModel.patient.fumo)
                if let sig = viewModel.patient.quanteSigarette, !sig.isEmpty {
                    PhysiologicalDetail(label: "Sigarette/giorno", value: sig)
                }
                PhysiologicalDetail(label: "Alcol", value: viewModel.patient.consumoAlcol)
                PhysiologicalDetail(label: "Caffè", value: viewModel.patient.consumoCaffe)
                if let eta = viewModel.patient.etaMestruazione {
                    PhysiologicalDetail(label: "Età prima mestruazione", value: "\(eta)")
                }
                PhysiologicalDetail(label: "Anomalie Ciclo", value: viewModel.patient.noteAnomalieCiclo)
                PhysiologicalDetail(label: "Gravidanze", value: viewModel.patient.gravidanze ? "Sì" : "No")
                PhysiologicalDetail(label: "Farmaci", value: viewModel.patient.qualiFarmaci)
                PhysiologicalDetail(label: "Alterazioni Esami", value: viewModel.patient.alterazioniEsamiSangue)
            }
        }
    }

    // MARK: - PDF
    private var pdfCard: some View {
        FormCard(icon: "doc.richtext", title: "ECG / Documenti", color: .purple) {
            if let pdfURL = viewModel.pdfFileURL {
                HStack(spacing: 16) {
                    Button { showingPDF = true } label: {
                        Label("Visualizza PDF", systemImage: "eye")
                            .font(.subheadline)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)

                    Button(role: .destructive) { viewModel.removePDF() } label: {
                        Label("Rimuovi", systemImage: "trash")
                            .font(.subheadline)
                    }
                    .buttonStyle(.bordered)
                }
                .sheet(isPresented: $showingPDF) {
                    PDFKitRepresentedView(url: pdfURL)
                        .edgesIgnoringSafeArea(.all)
                }
            } else {
                Button { showingDocumentPicker = true } label: {
                    Label("Carica PDF", systemImage: "plus.circle")
                        .font(.subheadline)
                }
                .buttonStyle(.borderedProminent)
                .tint(.purple)
                .fileImporter(isPresented: $showingDocumentPicker, allowedContentTypes: [.pdf]) { result in
                    switch result {
                    case .success(let url): viewModel.savePDF(url: url)
                    case .failure(let error): print("Errore PDF: \(error.localizedDescription)")
                    }
                }
            }
        }
    }

    // MARK: - Nota
    private var noteCard: some View {
        FormCard(icon: "note.text", title: "Nota Clinica", color: .gray) {
            VStack(spacing: 10) {
                if let nota = viewModel.patient.nota, !nota.isEmpty {
                    Text(nota)
                        .font(.body)
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        #if os(iOS)
                        .background(Color(.systemGray6))
                        #else
                        .background(Color(.controlBackgroundColor))
                        #endif
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    Text("Nessuna nota")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }

                TextField("Scrivi una nota...", text: $viewModel.noteText)
                    .padding(12)
                    #if os(iOS)
                    .background(Color(.systemGray6))
                    #else
                    .background(Color(.controlBackgroundColor))
                    #endif
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                Button(action: viewModel.saveNote) {
                    Label("Salva Nota", systemImage: "square.and.arrow.down")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - DetailRowView (per FormCard)
struct DetailRowView: View {
    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .top) {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: true, vertical: false)
            Spacer()
            Text(value)
                .font(.subheadline)
                .foregroundColor(.primary)
                .multilineTextAlignment(.trailing)
                .minimumScaleFactor(0.75)
        }
        .padding(.vertical, 3)
    }
}

// MARK: - PhysiologicalDetail
struct PhysiologicalDetail: View {
    let label: String
    let value: String?

    var body: some View {
        if let value, !value.isEmpty, value != "N/A" {
            DetailRowView(label: label, value: value)
        }
    }
}
