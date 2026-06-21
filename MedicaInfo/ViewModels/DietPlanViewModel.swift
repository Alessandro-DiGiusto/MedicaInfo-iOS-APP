import Foundation
import SwiftUI
import SwiftData
import CoreData

// MARK: - Day of week helper
extension Calendar {
    func startOfWeek(for date: Date) -> Date {
        let comps = dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return self.date(from: comps) ?? date
    }
}

@MainActor
class DietPlanViewModel: ObservableObject {
    
    // MARK: - Published State
    @Published var weekPlans: [DietPlan] = []
    @Published var selectedDayIndex = 0
    @Published var searchText = ""
    @Published var searchResults: [Alimento] = []
    @Published var isShowingSearch = false
    @Published var selectedMeal: Meal?
    
    // Patient selection
    @Published var patientNames: [String] = []
    @Published var selectedPatientIndex: Int = -1 {
        didSet { updatePatientOnPlans() }
    }
    @Published var selectedPatientName = ""
    
    // Computed: current day plan
    var currentPlan: DietPlan? {
        guard selectedDayIndex < weekPlans.count else { return nil }
        return weekPlans[selectedDayIndex]
    }
    
    // MARK: - Daily totals (reactive)
    @Published var totaleProteine: Double = 0
    @Published var totaleGrassi: Double = 0
    @Published var totaleCarboidrati: Double = 0
    @Published var totaleKcal: Double = 0
    @Published var totaleZuccheri: Double = 0
    
    var progressProteine: Double { currentPlan.map { $0.targetProteine > 0 ? totaleProteine / $0.targetProteine : 0 } ?? 0 }
    var progressGrassi: Double { currentPlan.map { $0.targetGrassi > 0 ? totaleGrassi / $0.targetGrassi : 0 } ?? 0 }
    var progressCarboidrati: Double { currentPlan.map { $0.targetCarboidrati > 0 ? totaleCarboidrati / $0.targetCarboidrati : 0 } ?? 0 }
    var progressKcal: Double { currentPlan.map { $0.targetKcal > 0 ? totaleKcal / $0.targetKcal : 0 } ?? 0 }
    
    private var modelContext: ModelContext?
    private var viewContext: NSManagedObjectContext?
    
    // MARK: - Setup
    
    func setup(modelContext: ModelContext, coreDataContext: NSManagedObjectContext) {
        self.modelContext = modelContext
        self.viewContext = coreDataContext
        loadPatients()
        loadOrCreateWeek()
    }
    
    // MARK: - Patient Loading
    private func loadPatients() {
        guard let ctx = viewContext else { return }
        let request: NSFetchRequest<Patient> = Patient.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Patient.surname, ascending: true)]
        do {
            let patients = try ctx.fetch(request)
            patientNames = patients.compactMap { p in
                guard let name = p.name, let surname = p.surname else { return nil }
                return "\(name) \(surname)"
            }
        } catch {
            print("[DietPlanVM] Errore caricamento pazienti: \(error)")
        }
    }
    
    private func updatePatientOnPlans() {
        guard selectedPatientIndex >= 0, selectedPatientIndex < patientNames.count else {
            selectedPatientName = ""
            return
        }
        selectedPatientName = patientNames[selectedPatientIndex]
        for plan in weekPlans {
            plan.patientName = selectedPatientName
        }
    }
    
    // MARK: - Week Management
    
    private func loadOrCreateWeek() {
        guard let context = modelContext else { return }
        
        let today = Date()
        let weekStart = Calendar.current.startOfWeek(for: today)
        let weekEnd = Calendar.current.date(byAdding: .day, value: 7, to: weekStart)!
        
        let descriptor = FetchDescriptor<DietPlan>(
            predicate: #Predicate { plan in
                plan.weekStartDate >= weekStart && plan.weekStartDate < weekEnd
            }
        )
        
        do {
            let existing = try context.fetch(descriptor)
            if existing.count == 7 {
                self.weekPlans = existing.sorted { $0.dayIndex < $1.dayIndex }
                // Restore patient
                if let name = existing.first?.patientName {
                    self.selectedPatientName = name
                    self.selectedPatientIndex = self.patientNames.firstIndex(of: name) ?? -1
                }
            } else {
                // Delete partial existing
                for plan in existing { context.delete(plan) }
                createNewWeek(from: weekStart, in: context)
            }
            refreshTotals()
        } catch {
            print("[DietPlanVM] Errore caricamento: \(error)")
            createNewWeek(from: weekStart, in: context)
        }
    }
    
    private func createNewWeek(from weekStart: Date, in context: ModelContext) {
        var plans: [DietPlan] = []
        for i in 0..<7 {
            let plan = DietPlan(
                weekStartDate: weekStart,
                dayIndex: i,
                patientID: nil,
                patientName: selectedPatientName
            )
            let meals = [
                Meal(name: "Colazione", orderIndex: 0),
                Meal(name: "Merenda", orderIndex: 1),
                Meal(name: "Pranzo", orderIndex: 2),
                Meal(name: "Spuntino", orderIndex: 3),
                Meal(name: "Cena", orderIndex: 4)
            ]
            for meal in meals {
                plan.meals.append(meal)
                meal.plan = plan
            }
            context.insert(plan)
            plans.append(plan)
        }
        self.weekPlans = plans
        saveContext()
    }
    
    // MARK: - Totals
    
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
        totaleProteine = p.rounded(to: 1)
        totaleGrassi = g.rounded(to: 1)
        totaleCarboidrati = c.rounded(to: 1)
        totaleKcal = k.rounded(to: 0)
        totaleZuccheri = z.rounded(to: 1)
    }
    
    func selectDay(_ index: Int) {
        selectedDayIndex = index
        refreshTotals()
        objectWillChange.send()
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
    
    func updateTargets(proteine: Double, grassi: Double, carboidrati: Double, kcal: Double, applyToAllDays: Bool) {
        if applyToAllDays {
            for plan in weekPlans {
                plan.targetProteine = proteine
                plan.targetGrassi = grassi
                plan.targetCarboidrati = carboidrati
                plan.targetKcal = kcal
            }
        } else if let plan = currentPlan {
            plan.targetProteine = proteine
            plan.targetGrassi = grassi
            plan.targetCarboidrati = carboidrati
            plan.targetKcal = kcal
        }
        saveAndRefresh()
    }
    
    func saveAll() {
        saveContext()
    }
    
    // MARK: - Persistence
    
    private func saveAndRefresh() {
        saveContext()
        refreshTotals()
        objectWillChange.send()
    }
    
    private func saveContext() {
        guard let context = modelContext else { return }
        do {
            try context.save()
        } catch {
            print("[DietPlanVM] Errore salvataggio: \(error)")
        }
    }
}

extension Double {
    func rounded(to places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
