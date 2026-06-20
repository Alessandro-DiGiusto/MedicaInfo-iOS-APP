import Foundation

class FoodDataLoader {
    static let shared = FoodDataLoader()
    
    private(set) var allFoods: [Alimento] = []
    private(set) var foodIndex: [String: Alimento] = [:]
    
    private init() {
        load()
    }
    
    private func load() {
        guard let url = Bundle.main.url(forResource: "alimenti", withExtension: "json") else {
            print("[FoodDataLoader] alimenti.json non trovato nel bundle")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let foods = try JSONDecoder().decode([Alimento].self, from: data)
            allFoods = foods.sorted { $0.nome < $1.nome }
            // Build index for O(1) lookup
            for food in allFoods {
                foodIndex[food.nome] = food
            }
            print("[FoodDataLoader] Caricati \(allFoods.count) alimenti")
        } catch {
            print("[FoodDataLoader] Errore caricamento: \(error)")
        }
    }
    
    /// Cerca alimenti per nome (case-insensitive, prefix match prima, poi contains)
    func search(query: String, maxResults: Int = 20) -> [Alimento] {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            return Array(allFoods.prefix(maxResults))
        }
        
        let lowercased = query.lowercased()
        
        // Priority: startsWith > contains
        let startsWith = allFoods.filter { $0.nome.lowercased().hasPrefix(lowercased) }
        let contains = allFoods.filter { $0.nome.lowercased().contains(lowercased) && !$0.nome.lowercased().hasPrefix(lowercased) }
        
        return Array((startsWith + contains).prefix(maxResults))
    }
}
