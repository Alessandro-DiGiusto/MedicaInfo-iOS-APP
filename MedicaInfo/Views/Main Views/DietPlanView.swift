import SwiftUI
import SwiftData

struct DietPlanView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = DietPlanViewModel()
    
    @State private var showingTargetEditor = false
    @State private var selectedMealForSearch: Meal?
    @State private var showingDatePicker = false
    
    var body: some View {
        Group {
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
        .frame(minWidth: 600, idealWidth: 900, maxWidth: .infinity,
               minHeight: 500, idealHeight: 700, maxHeight: .infinity)
        #if os(iOS)
        .background(Color(.systemGray6))
        #else
        .background(Color(.controlBackgroundColor))
        #endif
        .navigationTitle("Piano Alimentare")
        .toolbar {
            ToolbarItemGroup {
                Button(action: { showingDatePicker.toggle() }) {
                    Image(systemName: "calendar")
                }
                
                Button(action: { showingTargetEditor.toggle() }) {
                    Image(systemName: "target")
                }
                
                Spacer()
                
                Button(action: exportPlan) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .onAppear {
            viewModel.setup(modelContext: modelContext)
        }
        .sheet(isPresented: $showingTargetEditor) {
            TargetEditorView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingDatePicker) {
            DatePickerSheet(viewModel: viewModel)
        }
        .sheet(item: $selectedMealForSearch) { meal in
            FoodSearchView(viewModel: viewModel, meal: meal)
        }
    }
    
    // MARK: - Macro Summary Header
    
    private var macroSummaryHeader: some View {
        VStack(spacing: 8) {
            // Date + Targets
            HStack {
                if let plan = viewModel.currentPlan {
                    Text(plan.date, style: .date)
                        .font(.title2)
                        .fontWeight(.semibold)
                }
                Spacer()
                Text("Target: \(Int(viewModel.currentPlan?.targetKcal ?? 0)) kcal")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            // Macro bars
            HStack(spacing: 16) {
                MacroGaugeView(
                    label: "Proteine",
                    value: viewModel.totaleProteine,
                    target: viewModel.currentPlan?.targetProteine ?? 0,
                    unit: "g",
                    color: .blue
                )
                MacroGaugeView(
                    label: "Grassi",
                    value: viewModel.totaleGrassi,
                    target: viewModel.currentPlan?.targetGrassi ?? 0,
                    unit: "g",
                    color: .orange
                )
                MacroGaugeView(
                    label: "Carboidrati",
                    value: viewModel.totaleCarboidrati,
                    target: viewModel.currentPlan?.targetCarboidrati ?? 0,
                    unit: "g",
                    color: .green
                )
                MacroGaugeView(
                    label: "Energia",
                    value: viewModel.totaleKcal,
                    target: viewModel.currentPlan?.targetKcal ?? 0,
                    unit: "kcal",
                    color: .red
                )
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
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
                        description: Text("Crea un nuovo piano alimentare per oggi.")
                    )
                }
            }
            .padding()
        }
    }
    
    // MARK: - Export
    
    private func exportPlan() {
        // TODO: Generate PDF/summary of the plan
        print("[DietPlan] Export richiesto")
    }
}

// MARK: - Target Editor Sheet

struct TargetEditorView: View {
    @ObservedObject var viewModel: DietPlanViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var proteine: Double = 120
    @State private var grassi: Double = 60
    @State private var carboidrati: Double = 250
    @State private var kcal: Double = 2000
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Text("Proteine")
                        Spacer()
                        TextField("g", value: $proteine, format: .number)
                            .frame(width: 80)
                            .multilineTextAlignment(.trailing)
                        Text("g").foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Grassi")
                        Spacer()
                        TextField("g", value: $grassi, format: .number)
                            .frame(width: 80)
                            .multilineTextAlignment(.trailing)
                        Text("g").foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Carboidrati")
                        Spacer()
                        TextField("g", value: $carboidrati, format: .number)
                            .frame(width: 80)
                            .multilineTextAlignment(.trailing)
                        Text("g").foregroundColor(.secondary)
                    }
                    HStack {
                        Text("Energia")
                        Spacer()
                        TextField("kcal", value: $kcal, format: .number)
                            .frame(width: 80)
                            .multilineTextAlignment(.trailing)
                        Text("kcal").foregroundColor(.secondary)
                    }
                } header: {
                    Label("Target Giornalieri", systemImage: "target")
                } footer: {
                    Text("Imposta i valori massimi giornalieri per ogni macronutriente.")
                }
            }
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
                            kcal: kcal
                        )
                        dismiss()
                    }
                }
            }
            .onAppear {
                proteine = viewModel.currentPlan?.targetProteine ?? 120
                grassi = viewModel.currentPlan?.targetGrassi ?? 60
                carboidrati = viewModel.currentPlan?.targetCarboidrati ?? 250
                kcal = viewModel.currentPlan?.targetKcal ?? 2000
            }
        }
    }
}

// MARK: - Date Picker Sheet

struct DatePickerSheet: View {
    @ObservedObject var viewModel: DietPlanViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedDate = Date()
    
    var body: some View {
        NavigationStack {
            VStack {
                DatePicker("Seleziona data", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .padding()
            }
            .navigationTitle("Cambia Data")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annulla") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Vai") {
                        viewModel.createPlan(for: selectedDate)
                        dismiss()
                    }
                }
            }
        }
    }
}
