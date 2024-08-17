import Foundation

class DataLoader {
    func loadComuni() -> [Comune] {
        guard let url = Bundle.main.url(forResource: "comuni", withExtension: "json") else {
            print("File comuni.json non trovato")
            return []
        }
        
        do {
            let data = try Data(contentsOf: url)
            let comuni = try JSONDecoder().decode([Comune].self, from: data)
            return comuni
        } catch {
            print("Errore durante il caricamento dei comuni: \(error.localizedDescription)")
            return []
        }
    }
}
