import SwiftUI

struct FoodEntryRow: View {
    let entry: FoodEntry
    @ObservedObject var viewModel: DietPlanViewModel
    
    @State private var showQuantityEditor = false
    
    var body: some View {
        HStack(spacing: 10) {
            // Nome alimento
            Text(entry.foodName)
                .font(.body)
                .lineLimit(1)
            
            Spacer()
            
            // Quantità (tappabile per modificare)
            Button(action: { showQuantityEditor.toggle() }) {
                HStack(spacing: 4) {
                    Text("\(Int(entry.quantity))")
                        .font(.system(.callout, design: .rounded))
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                    Text("g")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Color.blue.opacity(0.08))
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            
            // Macro rapido
            HStack(spacing: 6) {
                MacroChip(value: entry.proteine, color: .blue)
                MacroChip(value: entry.grassi, color: .orange)
                MacroChip(value: entry.carboidrati, color: .green)
                Text("\(Int(entry.kcal))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(width: 36, alignment: .trailing)
            }
            .font(.caption2)
            
            // Elimina
            Button(action: { viewModel.removeFood(entry) }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(.red.opacity(0.6))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        #if os(iOS)
        .background(Color(.systemGray6))
        #else
        .background(Color(.controlBackgroundColor))
        #endif
        .alert("Modifica quantità", isPresented: $showQuantityEditor) {
            let binding = Binding<Double>(
                get: { entry.quantity },
                set: { viewModel.updateQuantity(for: entry, newQuantity: $0) }
            )
            // Use TextField with number
            TextField("Grammi", value: binding, format: .number)
                #if os(iOS)
                .keyboardType(.decimalPad)
                #endif
            Button("OK") { viewModel.refreshTotals() }
            Button("Annulla", role: .cancel) {}
        } message: {
            Text("Inserisci la quantità in grammi per \"\(entry.foodName)\"")
        }
    }
}

struct MacroChip: View {
    let value: Double
    let color: Color
    
    var body: some View {
        HStack(spacing: 2) {
            Circle()
                .fill(color)
                .frame(width: 5, height: 5)
            Text("\(Int(value))")
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    let entry = FoodEntry(foodName: "Pasta", quantity: 80,
                          proteinePer100: 12, grassiPer100: 1.5,
                          carboidratiPer100: 75, kcalPer100: 350, zuccheriPer100: 2)
    let vm = DietPlanViewModel()
    return FoodEntryRow(entry: entry, viewModel: vm)
        .padding()
}
