import Foundation
import SwiftUI
import SwiftData

@MainActor
class DietPlanViewModel: ObservableObject {
    // MARK: - Published State
    
    @Published var currentPlan: DietPlan?
    @Published var selectedMeal: Meal?
    @Published var searchText: String = ""
    @Published var searchResults: [Alimento] = []
    @Published var isShowingSearch = false
    
    // MARK: - Daily Totals (reactive)
    @Published var totaleProteine: Double = 0
    @Published var totaleGrassi: Double = 0
    @Published var totaleCarboidrati: Double = 0
    @Published var totaleKcal: Double = 0
    @Published var totaleZuccheri: Double = 0
    
    // MARK: - Computed progress (0.0 ... 1.0+)
    var progressProteine: Double { currentPlan.map { $0.targetProteine > 0 ? totaleProteine / $0.targetProteine : 0 } ?? 0 }
    var progressGrassi: Double { currentPlan.map { $0.targetGrassi > 0 ? totaleGrassi / $0.targetGrassi : 0 } ?? 0 }
    var progressCarboidrati: Double { currentPlan.map { $0.targetCarboidrati > 0 ? totaleCarboidrati / $0.targetCarboidrati : 0 } ?? 0 }
    var progressKcal: Double { currentPlan.map { $0.targetKcal > 0 ? totaleKcal / $0.targetKcal : 0 } ?? 0 }
    
    private var modelContext: ModelContext?
    private var observationTask: Task<Void, Never>?
    
    // MARK: - Setup
    
    func setup(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadOrCreateTodayPlan()
    }
    
    private func loadOrCreateTodayPlan() {
        guard let context = modelContext else { return }
        
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        let descriptor = FetchDescriptor<DietPlan>(
            predicate: #Predicate { plan in
                plan.date >= today && plan.date < tomorrow
            }
        )
        
        do {
            let plans = try context.fetch(descriptor)
            if let existing = plans.first {
                self.currentPlan = existing
                observePlan(existing)
            } else {
                let newPlan = DietPlan(date: today)
                // Create default meals
                let meals = [
                    Meal(name: "Colazione", orderIndex: 0),
                    Meal(name: "Pranzo", orderIndex: 1),
                    Meal(name: "Spuntino", orderIndex: 2),
                    Meal(name: "Cena", orderIndex: 3)
                ]
                for meal in meals {
                    newPlan.meals.append(meal)
                    meal.plan = newPlan
                }
                context.insert(newPlan)
                try context.save()
                self.currentPlan = newPlan
                observePlan(newPlan)
            }
        } catch {
            print("[DietPlanVM] Errore caricamento piano: \(error)")
        }
    }
    
    // MARK: - Reactive observation
    
    private func observePlan(_ plan: DietPlan) {
        // SwiftData @Model objects are observable via observation API.
        // We listen to changes in meals/entries through the SwiftData
        // modelContext and re-compute totals reactively.
        
        // Since SwiftData doesn't have built-in Combine publishers,
        // we use a manual refresh approach triggered by operations.
        refreshTotals()
    }
    
    func refreshTotals() {
        guard let plan = currentPlan else { return }
        let meals = plan.meals.sorted { $0.orderIndex < $1.orderIndex }
        
        var p: Double = 0, g: Double = 0, c: Double = 0, k: Double = 0, z: Double = 0
        for meal in meals {
            p += meal.totaleProteine
            g += meal.totaleGrassi
            c += meal.totaleCarboidrati
            k += meal.totaleKcal
            z += meal.totaleZuccheri
        }
        
        self.totaleProteine = p.rounded(to: 1)
        self.totaleGrassi = g.rounded(to: 1)
        self.totaleCarboidrati = c.rounded(to: 1)
        self.totaleKcal = k.rounded(to: 0)
        self.totaleZuccheri = z.rounded(to: 1)
    }
    
    // MARK: - Food Search
    
    func searchFoods(query: String) {
        searchResults = FoodDataLoader.shared.search(query: query)
    }
    
    // MARK: - Plan Mutations
    
    func addFood(_ alimento: Alimento, to meal: Meal, quantity: Double = 100) {
        let entry = FoodEntry(food: alimento, quantity: quantity)
        meal.entries.append(entry)
        entry.meal = meal
        saveAndRefresh()
    }
    
    func removeFood(_ entry: FoodEntry) {
        guard let context = modelContext else { return }
        context.delete(entry)
        saveAndRefresh()
    }
    
    func updateQuantity(for entry: FoodEntry, newQuantity: Double) {
        entry.quantity = max(10, newQuantity)
        saveAndRefresh()
    }
    
    func updateTargets(proteine: Double, grassi: Double, carboidrati: Double, kcal: Double) {
        guard let plan = currentPlan else { return }
        plan.targetProteine = proteine
        plan.targetGrassi = grassi
        plan.targetCarboidrati = carboidrati
        plan.targetKcal = kcal
        saveAndRefresh()
    }
    
    func createPlan(for date: Date) {
        guard let context = modelContext else { return }
        let newPlan = DietPlan(date: date)
        let meals = [
            Meal(name: "Colazione", orderIndex: 0),
            Meal(name: "Merenda", orderIndex: 1),
            Meal(name: "Pranzo", orderIndex: 2),
            Meal(name: "Spuntino", orderIndex: 3),
            Meal(name: "Cena", orderIndex: 4)
        ]
        for meal in meals {
            newPlan.meals.append(meal)
            meal.plan = newPlan
        }
        context.insert(newPlan)
        self.currentPlan = newPlan
        saveAndRefresh()
    }
    
    // MARK: - Persistence
    
    private func saveAndRefresh() {
        guard let context = modelContext else { return }
        do {
            try context.save()
            refreshTotals()
            
            // Post notification so SwiftUI picks up changes on computed properties
            objectWillChange.send()
        } catch {
            print("[DietPlanVM] Errore salvataggio: \(error)")
        }
    }
    
    deinit {
        observationTask?.cancel()
    }
}

// MARK: - Helper

extension Double {
    func rounded(to places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
