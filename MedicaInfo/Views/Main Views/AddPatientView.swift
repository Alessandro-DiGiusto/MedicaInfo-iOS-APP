import SwiftUI
import CoreData

// MARK: - AddPatientView - Professional Medical Form 2026
struct AddPatientView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: AddPatientViewModel

    // UI State
    @State private var showSuggestions = false
    @State private var showSuccessMessage = false
    @State private var isSaving = false
    @FocusState private var focusedField: Field?

    enum Field { case name, surname, cf, birthPlace, residence, phone }

    init() {
        _viewModel = StateObject(wrappedValue: AddPatientViewModel(
            context: PersistenceController.shared.container.viewContext
        ))
    }

    // MARK: - Body
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 20) {
                        headerSection
                        personalDataSection
                        sportSection
                        medicalConditionsSection
                        physiologicalSection
                        Color.clear.frame(height: 80) // spazio per sticky button
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
                #if os(iOS)
                .background(Color(.systemGroupedBackground).ignoresSafeArea())
                #else
                .background(Color(.controlBackgroundColor))
                #endif
                .scrollDismissesKeyboard(.interactively)
            }

            // Sticky Save Button
            stickySaveButton
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
        }
        .navigationTitle("Nuovo Paziente")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
        #endif
        .onAppear {
            // Comuni già caricati in modo sincrono dal ViewModel
        }
        .overlay(successOverlay)
    }

    // MARK: - Header
    private var headerSection: some View {
        VStack(spacing: 4) {
            Image(systemName: "person.crop.circle.fill.badge.plus")
                .font(.system(size: 48))
                .foregroundStyle(.linearGradient(colors: [.blue, .indigo], startPoint: .topLeading, endPoint: .bottomTrailing))
                .padding(.top, 8)

            Text("Inserisci i dati del paziente")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
    }

    // MARK: - 1. Dati Personali
    private var personalDataSection: some View {
        FormCard(icon: "person.text.rectangle", title: "Dati Personali", color: .blue) {
            VStack(spacing: 16) {
                LabelledTextField(
                    icon: "person",
                    label: "Nome",
                    text: $viewModel.name,
                    field: .name,
                    focus: $focusedField
                )
                LabelledTextField(
                    icon: "person.fill",
                    label: "Cognome",
                    text: $viewModel.surname,
                    field: .surname,
                    focus: $focusedField
                )

                // Data di nascita
                HStack(spacing: 12) {
                    Image(systemName: "calendar")
                        .font(.body)
                        .foregroundColor(.blue)
                        .frame(width: 20)
                    DatePicker("Data di nascita", selection: $viewModel.birthDate, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .labelsHidden()
                        .accentColor(.blue)
                    Spacer()
                }
                .padding(.horizontal, 4)

                LabelledTextField(
                    icon: "barcode.viewfinder",
                    label: "Codice Fiscale",
                    text: Binding(
                        get: { viewModel.cf.uppercased() },
                        set: { viewModel.cf = $0.uppercased() }
                    ),
                    field: .cf,
                    focus: $focusedField
                )
                #if os(iOS)
                .textInputAutocapitalization(.characters)
                #endif

                // Sesso
                HStack(spacing: 12) {
                    Image(systemName: "person.fill.questionmark")
                        .font(.body)
                        .foregroundColor(.blue)
                        .frame(width: 20)
                    Text("Sesso")
                        .foregroundColor(.primary)
                    Spacer()
                    Picker("", selection: $viewModel.gender) {
                        Text("Maschile").tag("Maschile")
                        Text("Femminile").tag("Femminile")
                    }
                    .pickerStyle(.segmented)
                    .frame(maxWidth: 200)
                }
                .padding(.horizontal, 4)

                // Comune di nascita con autocomplete
                birthPlaceField

                LabelledTextField(
                    icon: "house",
                    label: "Indirizzo di Residenza",
                    text: $viewModel.residenceAddress,
                    field: .residence,
                    focus: $focusedField
                )
                LabelledTextField(
                    icon: "phone",
                    label: "Telefono",
                    text: $viewModel.tel,
                    field: .phone,
                    focus: $focusedField
                )
                #if os(iOS)
                .keyboardType(.phonePad)
                #endif
            }
        }
    }

    // MARK: - Birth Place with Autocomplete
    private var birthPlaceField: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 12) {
                Image(systemName: "location")
                    .font(.body)
                    .foregroundColor(.blue)
                    .frame(width: 20)

                TextField("Comune di nascita", text: $viewModel.birthPlace)
                    .focused($focusedField, equals: .birthPlace)
                    .autocorrectionDisabled()
                    .onChange(of: viewModel.birthPlace) { _, newValue in
                        showSuggestions = !newValue.isEmpty && focusedField == .birthPlace
                    }
                    .onChange(of: focusedField) { _, newValue in
                        showSuggestions = newValue == .birthPlace && !viewModel.birthPlace.isEmpty
                    }
            }
            .padding(.horizontal, 4)

            // Suggestions dropdown
            if showSuggestions && !viewModel.filteredComuni.isEmpty {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(viewModel.filteredComuni) { comune in
                            Button {
                                viewModel.birthPlace = comune.nome
                                showSuggestions = false
                                focusedField = nil
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: "mappin.circle.fill")
                                        .foregroundColor(.blue)
                                        .font(.caption)
                                    Text(comune.nome)
                                        .foregroundColor(.primary)
                                        .font(.body)
                                    Spacer()
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)

                            if comune != viewModel.filteredComuni.last {
                                Divider().padding(.leading, 40)
                            }
                        }
                    }
                }
                .frame(maxHeight: 180)
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .black.opacity(0.12), radius: 8, y: 4)
                .transition(.move(edge: .top).combined(with: .opacity))
                .animation(.spring(response: 0.35, dampingFraction: 0.8), value: showSuggestions)
            }
        }
    }

    // MARK: - 2. Anamnesi Sportiva
    private var sportSection: some View {
        FormCard(icon: "sportscourt", title: "Anamnesi Sportiva", color: .orange) {
            Toggle(isOn: $viewModel.sportAnamnesis.animation(.smooth)) {
                Label("Sportiva", systemImage: "figure.run")
            }
            .tint(.orange)

            if viewModel.sportAnamnesis {
                Divider()
                VStack(spacing: 14) {
                    LabelledTextField(icon: "sportscourt", label: "Sport richiesto per la visita", text: $viewModel.requiredSport)

                    HStack(spacing: 12) {
                        Image(systemName: "clock").foregroundColor(.orange).frame(width: 20)
                        Text("Anni di pratica")
                        Spacer()
                        TextField("0", value: $viewModel.yearsOfPractice, format: .number)
                            #if os(iOS)
                            .keyboardType(.numberPad)
                            #endif
                            .multilineTextAlignment(.trailing)
                            .frame(width: 60)
                            .padding(8)
                            #if os(iOS)
                            .background(Color(.systemGray6))
                            #else
                            .background(Color(.controlBackgroundColor))
                            #endif
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    
                    HStack(spacing: 12) {
                        Image(systemName: "hourglass").foregroundColor(.orange).frame(width: 20)
                        Text("Ore / settimana")
                        Spacer()
                        TextField("0", value: $viewModel.weeklyHours, format: .number)
                            #if os(iOS)
                            .keyboardType(.numberPad)
                            #endif
                            .multilineTextAlignment(.trailing)
                            .frame(width: 60)
                            .padding(8)
                            #if os(iOS)
                            .background(Color(.systemGray6))
                            #else
                            .background(Color(.controlBackgroundColor))
                            #endif
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    
                    Toggle(isOn: $viewModel.practicesOtherSports.animation(.smooth)) {
                        Label("Pratica altri sport", systemImage: "ellipsis.circle")
                    }
                    .tint(.orange)

                    if viewModel.practicesOtherSports {
                        LabelledTextField(icon: "ellipsis.circle", label: "Dettagli altri sport", text: $viewModel.otherSportsDetails)
                    }

                    LabelledTextField(icon: "archivebox", label: "Sport praticati in passato", text: $viewModel.pastSports)
                }
                .padding(.leading, 4)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    // MARK: - 3. Condizioni Mediche
    private var medicalConditionsSection: some View {
        FormCard(icon: "heart.text.square", title: "Condizioni Mediche", color: .red) {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                MedConditionToggle(label: "Diabete Mellito", icon: "drop.fill", isOn: $viewModel.diabetesMellitus, color: .red)
                MedConditionToggle(label: "Malattie Cuore", icon: "heart", isOn: $viewModel.heartDisease, color: .pink)
                MedConditionToggle(label: "Malattie Tiroidee", icon: "thyroid", isOn: $viewModel.thyroidDiseases, color: .purple)
                MedConditionToggle(label: "Morte Improvvisa", icon: "exclamationmark.triangle", isOn: $viewModel.suddenDeath, color: .red)
                MedConditionToggle(label: "Mal. Polmonari", icon: "lungs", isOn: $viewModel.pulmonaryDiseases, color: .blue)
                MedConditionToggle(label: "Infarto Miocardio", icon: "bolt.heart", isOn: $viewModel.myocardialInfarction, color: .red)
                MedConditionToggle(label: "Cardiomiopatie", icon: "heart.slash", isOn: $viewModel.cardiomyopathies, color: .pink)
                MedConditionToggle(label: "Ipertensione", icon: "drop.triangle", isOn: $viewModel.hypertension, color: .orange)
                MedConditionToggle(label: "Colesterolo Alto", icon: "flame", isOn: $viewModel.highCholesterol, color: .orange)
                MedConditionToggle(label: "Celiachia", icon: "leaf", isOn: $viewModel.celiacDisease, color: .green)
                MedConditionToggle(label: "Ictus / Neurol.", icon: "brain", isOn: $viewModel.strokeNeurological, color: .purple)
                MedConditionToggle(label: "Tumori", icon: "cross.case", isOn: $viewModel.tumors, color: .red)
                MedConditionToggle(label: "Asma / Allergie", icon: "wind", isOn: $viewModel.asthmaAllergies, color: .blue)
                MedConditionToggle(label: "Obesità", icon: "scalemass", isOn: $viewModel.obesity, color: .orange)
                MedConditionToggle(label: "Mal. Genetiche", icon: "dna", isOn: $viewModel.geneticDiseases, color: .purple)
            }
        }
    }

    // MARK: - 4. Anamnesi Fisiologica
    private var physiologicalSection: some View {
        FormCard(icon: "person.crop.rectangle.stack", title: "Anamnesi Fisiologica", color: .teal) {
            PhysiologicalFormView(viewModel: viewModel)
        }
    }

    // MARK: - Sticky Save Button
    private var stickySaveButton: some View {
        Button {
            savePatient()
        } label: {
            HStack(spacing: 12) {
                if isSaving {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.white)
                } else {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                }
                Text(isSaving ? "Salvataggio..." : "Salva Paziente")
                    .font(.headline)
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(colors: [.blue, .indigo], startPoint: .leading, endPoint: .trailing)
            )
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .blue.opacity(0.3), radius: 12, y: 6)
        }
        .disabled(isSaving)
        .buttonStyle(.plain)
    }

    // MARK: - Actions
    private func savePatient() {
        isSaving = true
        focusedField = nil
        viewModel.savePatient()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isSaving = false
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                showSuccessMessage = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                withAnimation(.easeOut(duration: 0.3)) {
                    showSuccessMessage = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    dismiss()
                }
            }
        }
    }

    // MARK: - Success Overlay
    private var successOverlay: some View {
        Group {
            if showSuccessMessage {
                VStack {
                    Spacer()
                    HStack(spacing: 14) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                        Text("Paziente salvato")
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    .background(.green.gradient)
                    .clipShape(Capsule())
                    .shadow(color: .green.opacity(0.3), radius: 12, y: 6)
                    .padding(.bottom, 80)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: showSuccessMessage)
            }
        }
    }
}

// MARK: - Form Card Component
struct FormCard<Content: View>: View {
    let icon: String
    let title: String
    let color: Color
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.headline)
                    .foregroundColor(color)
                    .frame(width: 24)

                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)

                Spacer()
            }
            .padding(.bottom, 4)

            content()
        }
        .padding(16)
        #if os(iOS)
        .background(Color(.systemBackground))
        #else
        .background(Color(.windowBackgroundColor))
        #endif
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.04), radius: 6, y: 3)
    }
}

// MARK: - Labelled TextField
struct LabelledTextField: View {
    let icon: String
    let label: String
    @Binding var text: String
    var field: AddPatientView.Field?
    var focus: FocusState<AddPatientView.Field?>.Binding?

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundColor(.blue)
                .frame(width: 20)

            if let field, let focus {
                TextField(label, text: $text)
                    .focused(focus, equals: field)
                    .autocorrectionDisabled()
                    .minimumScaleFactor(0.8)
            } else {
                TextField(label, text: $text)
                    .autocorrectionDisabled()
                    .minimumScaleFactor(0.8)
            }
        }
        .padding(.horizontal, 4)
    }
}

// MARK: - Medical Condition Toggle (Grid)
struct MedConditionToggle: View {
    let label: String
    let icon: String
    @Binding var isOn: Bool
    let color: Color

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(isOn ? color : .secondary.opacity(0.4))
                .frame(width: 16)

            Text(label)
                .font(.caption)
                .fontWeight(isOn ? .semibold : .regular)
                .foregroundColor(isOn ? color : .secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Spacer(minLength: 4)

            Toggle("", isOn: $isOn)
                .tint(color)
                .labelsHidden()
                .scaleEffect(0.8)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        #if os(iOS)
            .background(isOn ? color.opacity(0.08) : Color(.systemGray6))
            #else
            .background(isOn ? color.opacity(0.08) : Color(.controlBackgroundColor))
            #endif
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .animation(.easeInOut(duration: 0.2), value: isOn)
    }
}

// MARK: - Anamnesi Fisiologica Form
struct PhysiologicalFormView: View {
    @ObservedObject var viewModel: AddPatientViewModel

    @State private var partoNaturaleSelection = ""
    @State private var altroInput = ""
    @State private var assumeFarmaci = false
    @State private var esamiSangue = false
    @State private var sceltaDieta = ""
    @State private var sceltaCaffe = ""
    @State private var consumoCaffe = ""

    var body: some View {
        VStack(spacing: 16) {
            // Parto
            PhysiologicalRow(icon: "figure.stand", label: "Parto naturale") {
                Picker("", selection: $partoNaturaleSelection) {
                    Text("NO").tag("NO")
                    Text("SI").tag("SI")
                    Text("Altro").tag("Altro")
                }
                .pickerStyle(.segmented)
                .onChange(of: partoNaturaleSelection) { _, newValue in
                    viewModel.partoNaturale = newValue == "Altro" ? altroInput : newValue
                }
            }
            if partoNaturaleSelection == "Altro" {
                TextField("Specifica", text: $altroInput)
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: altroInput) { _, newValue in viewModel.partoNaturale = newValue }
                    .padding(.leading, 32)
            }

            // Vaccinazioni
            PhysiologicalRow(icon: "syringe", label: "Vaccinazioni") {
                Picker("", selection: $viewModel.vaccinazioni) {
                    Text("NON LO SO").tag("NON LO SO")
                    Text("NO").tag("NO")
                    Text("SI").tag("SI")
                }
                .pickerStyle(.segmented)
            }

            // Farmaci
            PhysiologicalRow(icon: "pills", label: "Farmaci / Integratori") {
                Toggle(isOn: $assumeFarmaci.animation(.smooth)) { EmptyView() }.tint(.teal)
            }
            if assumeFarmaci {
                TextField("Se sì, quali?", text: $viewModel.qualiFarmaci)
                    .textFieldStyle(.roundedBorder)
                    .padding(.leading, 32)
            }

            // Esami sangue
            PhysiologicalRow(icon: "drop", label: "Esami del sangue (1 anno)") {
                Toggle(isOn: $esamiSangue.animation(.smooth)) { EmptyView() }.tint(.teal)
            }
            if esamiSangue {
                TextField("Alterazioni presenti?", text: $viewModel.alterazioniEsamiSangue)
                    .textFieldStyle(.roundedBorder)
                    .padding(.leading, 32)
            }

            // Dieta
            PhysiologicalRow(icon: "fork.knife", label: "Dieta") { EmptyView() }
            HStack(spacing: 8) {
                DietaButton(title: "Varia", selectedOption: $viewModel.dieta, optionValue: "Varia")
                DietaButton(title: "Vegana", selectedOption: $viewModel.dieta, optionValue: "Vegana")
                DietaButton(title: "Vegetariana", selectedOption: $viewModel.dieta, optionValue: "Vegetariana")
                DietaButton(title: "Speciale", selectedOption: $sceltaDieta, optionValue: "Speciale")
            }
            if sceltaDieta == "Speciale" {
                TextField("Specifica", text: Binding(
                    get: { viewModel.dieta.replacingOccurrences(of: "Speciale: ", with: "") },
                    set: { viewModel.dieta = "Speciale: \($0)" }
                ))
                .textFieldStyle(.roundedBorder)
                .padding(.leading, 8)
            }

            // Fumo
            PhysiologicalRow(icon: "smoke", label: "Fumatore") { EmptyView() }
            HStack(spacing: 8) {
                DietaButton(title: "NO", selectedOption: $viewModel.fumo, optionValue: "NO")
                DietaButton(title: "EX", selectedOption: $viewModel.fumo, optionValue: "EX")
                DietaButton(title: "SI", selectedOption: $viewModel.fumo, optionValue: "SI")
            }
            if viewModel.fumo == "SI" {
                HStack {
                    Image(systemName: "number").foregroundColor(.teal).frame(width: 20)
                    TextField("Sigarette al giorno", text: $viewModel.quanteSigarette)
                        .textFieldStyle(.roundedBorder)
                }
                .padding(.leading, 8)
            }

            // Alcol
            PhysiologicalRow(icon: "wineglass", label: "Alcol") { EmptyView() }
            HStack(spacing: 8) {
                DietaButton(title: "NO", selectedOption: $viewModel.consumoAlcol, optionValue: "NO")
                DietaButton(title: "SI", selectedOption: $viewModel.consumoAlcol, optionValue: "SI")
            }
            if viewModel.consumoAlcol == "SI" {
                HStack {
                    Image(systemName: "number").foregroundColor(.teal).frame(width: 20)
                    TextField("Quanto?", text: $viewModel.consumoAlcol)
                        .textFieldStyle(.roundedBorder)
                }
                .padding(.leading, 8)
            }

            // Caffè
            PhysiologicalRow(icon: "cup.and.saucer", label: "Caffè") { EmptyView() }
            HStack(spacing: 8) {
                DietaButton(title: "NO", selectedOption: $sceltaCaffe, optionValue: "NO")
                    .onChange(of: sceltaCaffe) { _, _ in
                        viewModel.consumoCaffe = sceltaCaffe == "NO" ? "NO" : consumoCaffe
                    }
                DietaButton(title: "SI", selectedOption: $sceltaCaffe, optionValue: "SI")
                    .onChange(of: sceltaCaffe) { _, _ in
                        viewModel.consumoCaffe = sceltaCaffe == "NO" ? "NO" : consumoCaffe
                    }
            }
            if sceltaCaffe == "SI" {
                HStack {
                    Image(systemName: "number").foregroundColor(.teal).frame(width: 20)
                    TextField("Tazzine al giorno", text: $consumoCaffe)
                        .textFieldStyle(.roundedBorder)
                        .onChange(of: consumoCaffe) { _, newValue in
                            viewModel.consumoCaffe = "SI: \(newValue)"
                        }
                }
                .padding(.leading, 8)
            }
        }
    }
}

// MARK: - Physiological Row
struct PhysiologicalRow<Content: View>: View {
    let icon: String
    let label: String
    @ViewBuilder let trailing: () -> Content

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundColor(.teal)
                .frame(width: 20)
            Text(label)
                .font(.subheadline)
                .foregroundColor(.primary)
            Spacer()
            trailing()
        }
        .padding(.horizontal, 4)
    }
}

#Preview {
    NavigationStack {
        AddPatientView()
    }
}
