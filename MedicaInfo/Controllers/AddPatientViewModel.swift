import Foundation
import CoreData
import Combine

final class AddPatientViewModel: ObservableObject {
    
    // MARK: - Published (triggerano UI updates)
    @Published var name = ""
    @Published var surname = ""
    @Published var birthDate = Date()
    @Published var cf = ""
    @Published var gender = "Maschile"
    @Published var birthPlace = ""
    @Published var selectedComuneNascita: Comune?
    @Published var residenceAddress = ""
    @Published var tel = ""
    
    @Published var sportAnamnesis = false
    @Published var requiredSport = ""
    @Published var yearsOfPractice: Int?
    @Published var weeklyHours: Int?
    @Published var practicesOtherSports = false
    @Published var otherSportsDetails = ""
    @Published var pastSports = ""
    
    // Condizioni Mediche
    @Published var diabetesMellitus = false
    @Published var heartDisease = false
    @Published var thyroidDiseases = false
    @Published var suddenDeath = false
    @Published var pulmonaryDiseases = false
    @Published var myocardialInfarction = false
    @Published var cardiomyopathies = false
    @Published var hypertension = false
    @Published var highCholesterol = false
    @Published var celiacDisease = false
    @Published var strokeNeurological = false
    @Published var tumors = false
    @Published var asthmaAllergies = false
    @Published var obesity = false
    @Published var geneticDiseases = false
    
    // Anamnesi Fisiologica
    @Published var partoNaturale = ""
    @Published var vaccinazioni = ""
    @Published var qualiFarmaci = ""
    @Published var alterazioniEsamiSangue = ""
    @Published var dieta = ""
    @Published var fumo = ""
    @Published var quanteSigarette = ""
    @Published var consumoAlcol = ""
    @Published var consumoCaffe = ""
    @Published var etaMestruazione: Decimal = 0
    @Published var dataUltimaMestruazione = Date()
    @Published var noteAnomalieCiclo = ""
    @Published var gravidanze = false
    @Published var dietaVaria = false
    @Published var dietaVegana = false
    @Published var dietaVegetariana = false
    @Published var dietaSpeciale = false
    @Published var scelta = ""
    
    // Comuni (non più @Published per evitare re-render inutili)
    private var allComuni: [Comune] = []
    @Published var filteredComuni: [Comune] = []
    
    private var cancellables = Set<AnyCancellable>()
    private var context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
        
        // Carica comuni dalla cache singleton (una tantum)
        self.allComuni = DataLoader.shared.loadComuniSync()
        self.filteredComuni = []
        
        // Pipeline di ricerca istantanea (nessun debounce — 8071 item, 0.5ms per ricerca)
        $birthPlace
            .removeDuplicates()
            .sink { [weak self] searchTerm in
                guard let self = self else { return }
                let trimmed = searchTerm.trimmingCharacters(in: .whitespaces)
                if trimmed.isEmpty {
                    self.filteredComuni = []
                } else {
                    self.filteredComuni = DataLoader.shared.searchComuni(query: trimmed, maxResults: 30)
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Salvataggio
    
    func savePatient() {
        let newPatient = Patient(context: context)
        newPatient.name = name
        newPatient.surname = surname
        newPatient.cf = cf
        newPatient.gender = gender
        newPatient.birthPlace = birthPlace
        newPatient.birthDate = birthDate
        newPatient.residenceAddress = residenceAddress
        newPatient.tel = tel
        newPatient.sportAnamnesis = sportAnamnesis
        newPatient.requiredSport = requiredSport
        newPatient.yearsOfPractice = Int16(yearsOfPractice ?? 0)
        newPatient.weeklyHours = Int16(weeklyHours ?? 0)
        newPatient.practicesOtherSports = practicesOtherSports
        newPatient.otherSportsDetails = otherSportsDetails
        newPatient.pastSports = pastSports
        newPatient.diabetesMellitus = diabetesMellitus
        newPatient.heartDisease = heartDisease
        newPatient.thyroidDiseases = thyroidDiseases
        newPatient.suddenDeath = suddenDeath
        newPatient.pulmonaryDiseases = pulmonaryDiseases
        newPatient.myocardialInfarction = myocardialInfarction
        newPatient.cardiomyopathies = cardiomyopathies
        newPatient.hypertension = hypertension
        newPatient.highCholesterol = highCholesterol
        newPatient.celiacDisease = celiacDisease
        newPatient.strokeNeurological = strokeNeurological
        newPatient.tumors = tumors
        newPatient.asthmaAllergies = asthmaAllergies
        newPatient.obesity = obesity
        newPatient.geneticDiseases = geneticDiseases
        newPatient.partoNaturale = partoNaturale
        newPatient.vaccinazioni = vaccinazioni
        newPatient.dieta = dieta
        newPatient.fumo = fumo
        newPatient.quanteSigarette = quanteSigarette
        
        if scelta.isEmpty {
            newPatient.consumoAlcol = consumoAlcol
        } else {
            newPatient.consumoAlcol = scelta
        }
        
        newPatient.consumoCaffe = consumoCaffe
        newPatient.etaMestruazione = NSDecimalNumber(decimal: etaMestruazione)
        newPatient.noteAnomalieCiclo = noteAnomalieCiclo
        newPatient.gravidanze = gravidanze
        
        if !qualiFarmaci.isEmpty { newPatient.qualiFarmaci = qualiFarmaci }
        if !alterazioniEsamiSangue.isEmpty { newPatient.alterazioniEsamiSangue = alterazioniEsamiSangue }
        
        do {
            try context.save()
        } catch {
            print("[AddPatientVM] Errore salvataggio: \(error)")
        }
    }
    
    func loadComuni() {
        self.allComuni = DataLoader.shared.loadComuniSync()
        self.filteredComuni = []
    }
}
