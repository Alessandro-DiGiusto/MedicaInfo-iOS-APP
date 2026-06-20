import Foundation

// MARK: - DataLoader con cache singleton
final class DataLoader {
    
    static let shared = DataLoader()
    
    private var cachedComuni: [Comune]?
    private var cachedLowercased: [String]?
    
    private init() {}
    
    /// Carica i comuni con cache — letto una volta sola, poi riusato
    func loadComuniSync() -> [Comune] {
        if let cached = cachedComuni { return cached }
        guard let url = Bundle.main.url(forResource: "comuni", withExtension: "json") else {
            print("[DataLoader] comuni.json non trovato")
            return []
        }
        do {
            let data = try Data(contentsOf: url)
            let comuni = try JSONDecoder().decode([Comune].self, from: data)
            cachedComuni = comuni
            // Pre-compute lowercase per filtri ultra-veloci
            cachedLowercased = comuni.map { $0.nome.lowercased() }
            print("[DataLoader] Caricati \(comuni.count) comuni (cached)")
            return comuni
        } catch {
            print("[DataLoader] Errore: \(error)")
            return []
        }
    }
    
    /// Accesso rapido ai nomi lowercased (per filtri senza ripetere il mapping)
    func lowercasedNames() -> [String] {
        if let cached = cachedLowercased { return cached }
        _ = loadComuniSync()
        return cachedLowercased ?? []
    }
    
    /// Ricerca ottimizzata: single-pass, pre-lowercased, prioritize prefix
    func searchComuni(query: String, maxResults: Int = 30) -> [Comune] {
        let comuni = loadComuniSync()
        guard !comuni.isEmpty else { return [] }
        
        let trimmed = query.trimmingCharacters(in: .whitespaces).lowercased()
        guard !trimmed.isEmpty else { return [] }
        
        let names = lowercasedNames()
        
        var startsWith: [Comune] = []
        var contains: [Comune] = []
        startsWith.reserveCapacity(32)
        contains.reserveCapacity(32)
        
        for i in comuni.indices {
            let lower = names[i]
            if lower.hasPrefix(trimmed) {
                startsWith.append(comuni[i])
                if startsWith.count >= maxResults { break }
            }
        }
        
        if startsWith.count < maxResults {
            let remaining = maxResults - startsWith.count
            for i in comuni.indices {
                let lower = names[i]
                if lower.hasPrefix(trimmed) { continue } // già in startsWith
                if lower.contains(trimmed) {
                    contains.append(comuni[i])
                    if contains.count >= remaining { break }
                }
            }
        }
        
        return startsWith + contains
    }
    
    /// Mantenuto per retrocompatibilità
    func loadComuni(completion: @escaping ([Comune]) -> Void) {
        let result = loadComuniSync()
        DispatchQueue.main.async { completion(result) }
    }
}
