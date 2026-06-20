import SwiftUI

struct MealSectionView: View {
    let meal: Meal
    @ObservedObject var viewModel: DietPlanViewModel
    let onAdd: () -> Void
    
    @State private var isExpanded = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            Button(action: { withAnimation(.smooth) { isExpanded.toggle() } }) {
                HStack {
                    // Icona pasto
                    Image(systemName: mealIcon)
                        .font(.title3)
                        .foregroundColor(mealColor)
                        .frame(width: 28)
                    
                    Text(meal.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    // Macro riepilogo del pasto
                    HStack(spacing: 12) {
                        MacroPill(value: meal.totaleKcal, unit: "kcal", color: .red)
                        MacroPill(value: meal.totaleProteine, unit: "p", color: .blue)
                        MacroPill(value: meal.totaleGrassi, unit: "g", color: .orange)
                        MacroPill(value: meal.totaleCarboidrati, unit: "c", color: .green)
                    }
                    .font(.caption2)
                    
                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        .animation(.smooth, value: isExpanded)
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 12)
                #if os(iOS)
                .background(Color(.systemBackground))
                #else
                .background(Color(.windowBackgroundColor))
                #endif
            }
            .buttonStyle(.plain)
            
            if isExpanded {
                // Lista alimenti
                if meal.entries.isEmpty {
                    emptyState
                } else {
                    ForEach(meal.entries) { entry in
                        FoodEntryRow(entry: entry, viewModel: viewModel)
                    }
                }
                
                // Bottone aggiungi
                Button(action: onAdd) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.blue)
                        Text("Aggiungi alimento")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                }
                .buttonStyle(.plain)
            }
        }
        #if os(iOS)
        .background(Color(.systemBackground))
        #else
        .background(Color(.windowBackgroundColor))
        #endif
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.04), radius: 4, y: 2)
    }
    
    private var emptyState: some View {
        HStack {
            Spacer()
            Text("Nessun alimento — tocca \"Aggiungi\" per iniziare")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.vertical, 8)
            Spacer()
        }
    }
    
    private var mealIcon: String {
        switch meal.name {
        case "Colazione": return "sunrise.fill"
        case "Merenda": return "cup.and.saucer.fill"
        case "Pranzo": return "sun.max.fill"
        case "Spuntino": return "moonphase.waning.crescent"
        case "Cena": return "moon.stars.fill"
        default: return "fork.knife"
        }
    }
    
    private var mealColor: Color {
        switch meal.name {
        case "Colazione": return .yellow
        case "Merenda": return .teal
        case "Pranzo": return .orange
        case "Spuntino": return .purple
        case "Cena": return .indigo
        default: return .gray
        }
    }
}

// MARK: - Macro Pill (small badge)

struct MacroPill: View {
    let value: Double
    let unit: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 2) {
            Text("\(Int(value))")
                .fontWeight(.semibold)
                .foregroundColor(color)
            Text(unit)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(color.opacity(0.1))
        .clipShape(Capsule())
    }
}

#Preview {
    let meal = Meal(name: "Pranzo", orderIndex: 1)
    let vm = DietPlanViewModel()
    return MealSectionView(meal: meal, viewModel: vm, onAdd: {})
        .padding()
}
