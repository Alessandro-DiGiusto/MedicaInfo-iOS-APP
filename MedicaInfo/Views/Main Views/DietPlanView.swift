import SwiftUI
import SwiftData
import CoreData

// MARK: - DietPlanView with 7-day week
struct DietPlanView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel = DietPlanViewModel()

    @State private var showingTargetEditor = false
    @State private var selectedMealForSearch: Meal?
    @State private var showingPatientPicker = false

    private let dayLabels = ["Lun", "Mar", "Mer", "Gio", "Ven", "Sab", "Dom"]

    var body: some View {
        VStack(spacing: 0) {
            // Patient selector
            patientHeader

            // Day selector
            daySelector

            // Main content
            #if os(macOS)
            VSplitView {
                macroSummaryHeader
                mealsList
            }
            #else
            VStack(spacing: 0) {
                macroSummaryHeader
                mealsList
            }
            #endif
        }
        #if os(iOS)
        .background(Color(.systemGray6))
        #else
        .background(Color(.controlBackgroundColor))
        #endif
        .navigationTitle("Piano Alimentare")
        .toolbar {
            ToolbarItemGroup {
                Button { showingTargetEditor.toggle() } label: {
                    Image(systemName: "target")
                }

                Spacer()

                Button { viewModel.saveAll() } label: {
                    Image(systemName: "square.and.arrow.down")
                }
            }
        }
        .onAppear {
            viewModel.setup(
                modelContext: modelContext,
                coreDataContext: viewContext
            )
        }
        .sheet(isPresented: $showingTargetEditor) {
            TargetEditorView(viewModel: viewModel)
                #if os(macOS)
                .frame(width: 400, height: 320)
                #endif
        }
        .sheet(item: $selectedMealForSearch) { meal in
            FoodSearchView(viewModel: viewModel, meal: meal)
                #if os(macOS)
                .frame(minWidth: 520, minHeight: 500)
                #endif
        }
        .sheet(isPresented: $showingPatientPicker) {
            PatientPickerView(viewModel: viewModel)
                #if os(macOS)
                .frame(width: 400, height: 400)
                #endif
        }
        .onChange(of: viewModel.selectedDayIndex) { _, _ in
            viewModel.refreshTotals()
        }
    }

    // MARK: - Patient Header
    private var patientHeader: some View {
        HStack {
            Image(systemName: "person.fill")
                .foregroundColor(.blue)
            if viewModel.selectedPatientName.isEmpty {
                Text("Nessun paziente selezionato")
                    .foregroundColor(.secondary)
            } else {
                Text(viewModel.selectedPatientName)
                    .fontWeight(.semibold)
            }
            Spacer()
            Button { showingPatientPicker = true } label: {
                Text(viewModel.selectedPatientName.isEmpty ? "Seleziona" : "Cambia")
                    .font(.subheadline)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(.thinMaterial)
    }

    // MARK: - Day Selector
    private var daySelector: some View {
        HStack(spacing: 0) {
            ForEach(0..<7, id: \.self) { i in
                Button {
                    viewModel.selectDay(i)
                } label: {
                    VStack(spacing: 2) {
                        Text(dayLabels[i])
                            .font(.caption2)
                            .foregroundColor(viewModel.selectedDayIndex == i ? .white : .secondary)
                        Text(viewModel.weekPlans.indices.contains(i) ? "\(Int(viewModel.weekPlans[i].totaleKcal))" : "-")
                            .font(.caption.weight(.bold))
                            .foregroundColor(viewModel.selectedDayIndex == i ? .white : .primary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(viewModel.selectedDayIndex == i ? Color.blue : Color.clear)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(.regularMaterial)
    }

    // MARK: - Macro Summary
    private var macroSummaryHeader: some View {
        VStack(spacing: 8) {
            if let plan = viewModel.currentPlan {
                HStack {
                    Text(plan.dayName)
                        .font(.title2.weight(.semibold))
                    Spacer()
                    Text("Target: \(Int(plan.targetKcal)) kcal")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                .padding(.top, 8)

                HStack(spacing: 12) {
                    MacroGaugeView(label: "Proteine", value: viewModel.totaleProteine, target: plan.targetProteine, unit: "g", color: .blue)
                    MacroGaugeView(label: "Grassi", value: viewModel.totaleGrassi, target: plan.targetGrassi, unit: "g", color: .orange)
                    MacroGaugeView(label: "Carboidrati", value: viewModel.totaleCarboidrati, target: plan.targetCarboidrati, unit: "g", color: .green)
                    MacroGaugeView(label: "Energia", value: viewModel.totaleKcal, target: plan.targetKcal, unit: "kcal", color: .red)
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
        }
        #if os(iOS)
        .background(Color(.systemBackground))
        #else
        .background(Color(.windowBackgroundColor))
        #endif
    }

    // MARK: - Meals List
    private var mealsList: some View {
        ScrollView {
            VStack(spacing: 12) {
                if let plan = viewModel.currentPlan {
                    let meals = plan.meals.sorted { $0.orderIndex < $1.orderIndex }
                    ForEach(meals) { meal in
                        MealSectionView(meal: meal, viewModel: viewModel) {
                            selectedMealForSearch = meal
                        }
                    }
                } else {
                    ContentUnavailableView(
                        "Nessun Piano",
                        systemImage: "fork.knife",
                        description: Text("Crea un nuovo piano per il paziente selezionato.")
                    )
                }
            }
            .padding()
        }
    }
}

// MARK: - Patient Picker
struct PatientPickerView: View {
    @ObservedObject var viewModel: DietPlanViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                if viewModel.patientNames.isEmpty {
                    ContentUnavailableView(
                        "Nessun paziente",
                        systemImage: "person.slash",
                        description: Text("Aggiungi prima un paziente dalla schermata home.")
                    )
                } else {
                    ForEach(Array(viewModel.patientNames.enumerated()), id: \.offset) { index, name in
                        Button {
                            viewModel.selectedPatientIndex = index
                            dismiss()
                        } label: {
                            HStack {
                                Image(systemName: "person.circle")
                                    .foregroundColor(.blue)
                                Text(name)
                                    .foregroundColor(.primary)
                                Spacer()
                                if index == viewModel.selectedPatientIndex {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .navigationTitle("Seleziona Paziente")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Annulla") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Target Editor (Adaptive Layout con LabeledContent)
struct TargetEditorView: View {
    @ObservedObject var viewModel: DietPlanViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var proteine: Double = 120
    @State private var grassi: Double = 60
    @State private var carboidrati: Double = 250
    @State private var kcal: Double = 2000
    @State private var applyToAllDays = true

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    LabeledContent("Proteine") {
                        HStack(spacing: 4) {
                            TextField("", value: $proteine, format: .number)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 80)
                                .fixedSize(horizontal: true, vertical: false)
                            Text("g")
                                .foregroundColor(.secondary)
                                .fixedSize()
                        }
                    }
                    LabeledContent("Grassi") {
                        HStack(spacing: 4) {
                            TextField("", value: $grassi, format: .number)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 80)
                                .fixedSize(horizontal: true, vertical: false)
                            Text("g")
                                .foregroundColor(.secondary)
                                .fixedSize()
                        }
                    }
                    LabeledContent("Carboidrati") {
                        HStack(spacing: 4) {
                            TextField("", value: $carboidrati, format: .number)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 80)
                                .fixedSize(horizontal: true, vertical: false)
                            Text("g")
                                .foregroundColor(.secondary)
                                .fixedSize()
                        }
                    }
                    LabeledContent("Energia") {
                        HStack(spacing: 4) {
                            TextField("", value: $kcal, format: .number)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 80)
                                .fixedSize(horizontal: true, vertical: false)
                            Text("kcal")
                                .foregroundColor(.secondary)
                                .fixedSize()
                        }
                    }
                } header: {
                    Label("Target Giornalieri", systemImage: "target")
                }

                Section {
                    Toggle("Applica a tutti i giorni", isOn: $applyToAllDays)
                        .tint(.blue)
                } footer: {
                    Text(applyToAllDays
                        ? "I target saranno uguali per tutti i 7 giorni della settimana."
                        : "I target verranno applicati solo a \(viewModel.currentPlan?.dayName ?? "oggi").")
                }
            }
            #if os(macOS)
            .frame(minWidth: 380, idealWidth: 420, maxWidth: 500)
            #endif
            .navigationTitle("Modifica Target")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annulla") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salva") {
                        viewModel.updateTargets(
                            proteine: proteine,
                            grassi: grassi,
                            carboidrati: carboidrati,
                            kcal: kcal,
                            applyToAllDays: applyToAllDays
                        )
                        dismiss()
                    }
                }
            }
            .onAppear {
                if let plan = viewModel.currentPlan {
                    proteine = plan.targetProteine
                    grassi = plan.targetGrassi
                    carboidrati = plan.targetCarboidrati
                    kcal = plan.targetKcal
                }
            }
        }
    }
}