import Foundation
import SwiftData

// MARK: - Alimento (da JSON database)
struct Alimento: Codable, Identifiable, Hashable {
    var id: String { nome }
    let nome: String
    let proteine: Double
    let grassi: Double
    let carboidrati: Double
    let kcal: Double
    let zuccheri: Double
}

// MARK: - DietPlan
@Model
final class DietPlan {
    @Attribute(.unique) var id: UUID
    var weekStartDate: Date      // Lunedì della settimana
    var dayIndex: Int            // 0=Lunedì ... 6=Domenica
    var note: String
    
    // Associazione paziente (denormalizzato da Core Data)
    var patientID: UUID?
    var patientName: String?
    
    // Macro targets giornalieri
    var targetProteine: Double
    var targetGrassi: Double
    var targetCarboidrati: Double
    var targetKcal: Double
    
    @Relationship(deleteRule: .cascade) var meals: [Meal]
    
    var dayName: String {
        let days = ["Lunedì", "Martedì", "Mercoledì", "Giovedì", "Venerdì", "Sabato", "Domenica"]
        guard dayIndex >= 0, dayIndex < days.count else { return "?" }
        return days[dayIndex]
    }
    
    var date: Date {
        Calendar.current.date(byAdding: .day, value: dayIndex, to: weekStartDate) ?? weekStartDate
    }

    var totaleKcal: Double { meals.reduce(0) { $0 + $1.totaleKcal } }
    var totaleProteine: Double { meals.reduce(0) { $0 + $1.totaleProteine } }
    var totaleGrassi: Double { meals.reduce(0) { $0 + $1.totaleGrassi } }
    var totaleCarboidrati: Double { meals.reduce(0) { $0 + $1.totaleCarboidrati } }

    init(
        id: UUID = UUID(),
        weekStartDate: Date,
        dayIndex: Int,
        note: String = "",
        patientID: UUID? = nil,
        patientName: String? = nil,
        targetProteine: Double = 120,
        targetGrassi: Double = 60,
        targetCarboidrati: Double = 250,
        targetKcal: Double = 2000
    ) {
        self.id = id
        self.weekStartDate = weekStartDate
        self.dayIndex = dayIndex
        self.note = note
        self.patientID = patientID
        self.patientName = patientName
        self.targetProteine = targetProteine
        self.targetGrassi = targetGrassi
        self.targetCarboidrati = targetCarboidrati
        self.targetKcal = targetKcal
        self.meals = []
    }
}

// MARK: - Meal
@Model
final class Meal {
    @Attribute(.unique) var id: UUID
    var name: String       // "Colazione", "Pranzo", "Spuntino", "Cena"
    var orderIndex: Int
    
    @Relationship(deleteRule: .cascade) var entries: [FoodEntry]
    var plan: DietPlan?
    
    init(id: UUID = UUID(), name: String, orderIndex: Int) {
        self.id = id
        self.name = name
        self.orderIndex = orderIndex
        self.entries = []
    }
    
    // MARK: - Computed totals for this meal
    
    var totaleProteine: Double { entries.reduce(0) { $0 + $1.proteine } }
    var totaleGrassi: Double { entries.reduce(0) { $0 + $1.grassi } }
    var totaleCarboidrati: Double { entries.reduce(0) { $0 + $1.carboidrati } }
    var totaleKcal: Double { entries.reduce(0) { $0 + $1.kcal } }
    var totaleZuccheri: Double { entries.reduce(0) { $0 + $1.zuccheri } }
}

// MARK: - FoodEntry
@Model
final class FoodEntry {
    @Attribute(.unique) var id: UUID
    var foodName: String
    var quantity: Double // grammi
    
    // Valori per 100g (snapshot dal database)
    var proteinePer100: Double
    var grassiPer100: Double
    var carboidratiPer100: Double
    var kcalPer100: Double
    var zuccheriPer100: Double
    
    var meal: Meal?
    
    init(
        id: UUID = UUID(),
        foodName: String,
        quantity: Double,
        proteinePer100: Double,
        grassiPer100: Double,
        carboidratiPer100: Double,
        kcalPer100: Double,
        zuccheriPer100: Double
    ) {
        self.id = id
        self.foodName = foodName
        self.quantity = quantity
        self.proteinePer100 = proteinePer100
        self.grassiPer100 = grassiPer100
        self.carboidratiPer100 = carboidratiPer100
        self.kcalPer100 = kcalPer100
        self.zuccheriPer100 = zuccheriPer100
    }
    
    convenience init(food: Alimento, quantity: Double = 100) {
        self.init(
            foodName: food.nome,
            quantity: quantity,
            proteinePer100: food.proteine,
            grassiPer100: food.grassi,
            carboidratiPer100: food.carboidrati,
            kcalPer100: food.kcal,
            zuccheriPer100: food.zuccheri
        )
    }
    
    // MARK: - Computed values based on quantity
    
    var proteine: Double { quantity * proteinePer100 / 100 }
    var grassi: Double { quantity * grassiPer100 / 100 }
    var carboidrati: Double { quantity * carboidratiPer100 / 100 }
    var kcal: Double { quantity * kcalPer100 / 100 }
    var zuccheri: Double { quantity * zuccheriPer100 / 100 }
}
