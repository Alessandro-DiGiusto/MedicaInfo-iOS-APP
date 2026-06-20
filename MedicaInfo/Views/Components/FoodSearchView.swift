import SwiftUI

struct FoodSearchView: View {
    @ObservedObject var viewModel: DietPlanViewModel
    let meal: Meal
    
    @Environment(\.dismiss) private var dismiss
    @State private var searchText: String = ""
    @State private var selectedQuantity: Double = 100
    @State private var results: [Alimento] = []
    @State private var showQuantityPicker = false
    @State private var selectedFood: Alimento?
    
    private let foodLoader = FoodDataLoader.shared
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Cerca alimento...", text: $searchText)
                        .autocorrectionDisabled()
                        .onChange(of: searchText) { _, newValue in
                            results = foodLoader.search(query: newValue)
                        }
                    
                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(10)
                #if os(iOS)
                .background(Color(.systemGray6))
                #else
                .background(Color(.controlBackgroundColor))
                #endif
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding()
                
                // Results
                if results.isEmpty {
                    ContentUnavailableView(
                        "Cerca un alimento",
                        systemImage: "magnifyingglass",
                        description: Text("Inizia a digitare per cercare nel database di \(foodLoader.allFoods.count) alimenti.")
                    )
                } else {
                    List {
                        ForEach(results) { alimento in
                            Button(action: { selectFood(alimento) }) {
                                FoodSearchRow(alimento: alimento)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Aggiungi a \(meal.name)")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annulla") { dismiss() }
                }
            }
            .onAppear {
                results = foodLoader.search(query: "")
            }
            .alert("Quantità", isPresented: $showQuantityPicker, presenting: selectedFood) { alimento in
                TextField("Grammi", value: $selectedQuantity, format: .number)
                    #if os(iOS)
                    .keyboardType(.decimalPad)
                    #endif
                Button("Aggiungi") {
                    viewModel.addFood(alimento, to: meal, quantity: selectedQuantity)
                    dismiss()
                }
                Button("Annulla", role: .cancel) {}
            } message: { alimento in
                Text("Quanti grammi di \"\(alimento.nome)\" vuoi aggiungere?")
            }
        }
    }
    
    private func selectFood(_ alimento: Alimento) {
        selectedFood = alimento
        selectedQuantity = 100
        showQuantityPicker = true
    }
}

// MARK: - Food Search Row

struct FoodSearchRow: View {
    let alimento: Alimento
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(alimento.nome)
                    .font(.body)
                    .foregroundColor(.primary)
                
                HStack(spacing: 8) {
                    Label("\(Int(alimento.kcal)) kcal", systemImage: "flame")
                    Label("\(alimento.proteine, specifier: "%.1f")g prot", systemImage: "p.circle")
                    Label("\(alimento.grassi, specifier: "%.1f")g gras", systemImage: "g.circle")
                    Label("\(alimento.carboidrati, specifier: "%.1f")g carb", systemImage: "c.circle")
                }
                .font(.caption2)
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "plus.circle")
                .foregroundColor(.blue)
                .font(.title3)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    FoodSearchView(viewModel: DietPlanViewModel(), meal: Meal(name: "Pranzo", orderIndex: 1))
}
