
import Foundation

class DataLoader {
    func loadComuni(completion: @escaping ([Comune]) -> Void) {
        DispatchQueue.global(qos: .background).async {
            guard let url = Bundle.main.url(forResource: "comuni", withExtension: "json") else {
                print("File comuni.json non trovato")
                DispatchQueue.main.async {
                    completion([])
                }
                return
            }
            
            do {
                let data = try Data(contentsOf: url)
                let comuni = try JSONDecoder().decode([Comune].self, from: data)
                DispatchQueue.main.async {
                    completion(comuni)
                }
            } catch {
                print("Errore durante il caricamento dei comuni: \(error)")
                DispatchQueue.main.async {
                    completion([])
                }
            }
        }
    }
}
