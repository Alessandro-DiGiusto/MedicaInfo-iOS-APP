import Foundation
import CoreData
import Combine

class AddPatientViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var surname: String = ""
    @Published var birthDate: Date = Date()
    @Published var cf: String = ""
    @Published var gender: String = "Maschile"
    @Published var birthPlace: String = ""
    @Published var selectedComuneNascita: Comune?
    @Published var residenceAddress: String = ""
    @Published var tel: String = ""
    
    @Published var sportAnamnesis: Bool = false
    @Published var requiredSport: String = ""
    @Published var yearsOfPractice: Int?
    @Published var weeklyHours: Int?
    @Published var practicesOtherSports: Bool = false
    @Published var otherSportsDetails: String = ""
    @Published var pastSports: String = ""
    
    @Published var diabetesMellitus: Bool = false
    @Published var heartDisease: Bool = false
    @Published var thyroidDiseases: Bool = false
    @Published var suddenDeath: Bool = false
    @Published var pulmonaryDiseases: Bool = false
    @Published var myocardialInfarction: Bool = false
    @Published var cardiomyopathies: Bool = false
    @Published var hypertension: Bool = false
    @Published var highCholesterol: Bool = false
    @Published var celiacDisease: Bool = false
    @Published var strokeNeurological: Bool = false
    @Published var tumors: Bool = false
    @Published var asthmaAllergies: Bool = false
    @Published var obesity: Bool = false
    @Published var geneticDiseases: Bool = false
    
    // Anamnesi Fisiologica
    @Published var partoNaturale: String = ""
    @Published var vaccinazioni: String = ""
    @Published var qualiFarmaci: String = ""
    @Published var alterazioniEsamiSangue: String = ""
    @Published var dieta: String = ""
    @Published var fumo: String = ""
    @Published var quanteSigarette: String = ""
    @Published var consumoAlcol: String = ""
    @Published var consumoCaffe: String = ""
    @Published var etaMestruazione: Decimal = 0
    @Published var noteAnomalieCiclo: String = ""
    @Published var gravidanze: Bool = false
    
    @Published var comuni: [Comune] = []
    @Published var filteredComuni: [Comune] = []
    
    private var cancellables: Set<AnyCancellable> = []
    private var context: NSManagedObjectContext
    
    init(patient: Patient? = nil, context: NSManagedObjectContext) {
        self.context = context
        loadComuni()
        
        // Filtra i comuni quando cambia il campo di testo birthPlace
        $birthPlace
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .map { searchTerm in
                self.comuni.filter { $0.nome.lowercased().contains(searchTerm.lowercased()) }
            }
            .assign(to: &$filteredComuni)
        
        if let patient = patient {
            // Popola le variabili se esiste un paziente (in caso di modifica)
            self.name = patient.name ?? ""
            self.surname = patient.surname ?? ""
            self.birthDate = patient.birthDate ?? Date()
            self.cf = patient.cf ?? ""
            self.gender = patient.gender ?? "Maschile"
            self.birthPlace = patient.birthPlace ?? ""
            self.residenceAddress = patient.residenceAddress ?? ""
            self.tel = patient.tel ?? ""
            self.sportAnamnesis = patient.sportAnamnesis
            self.requiredSport = patient.requiredSport ?? ""
            self.yearsOfPractice = Int(patient.yearsOfPractice)
            self.weeklyHours = Int(patient.weeklyHours)
            self.practicesOtherSports = patient.practicesOtherSports
            self.otherSportsDetails = patient.otherSportsDetails ?? ""
            self.pastSports = patient.pastSports ?? ""
            self.diabetesMellitus = patient.diabetesMellitus
            self.heartDisease = patient.heartDisease
            self.thyroidDiseases = patient.thyroidDiseases
            self.suddenDeath = patient.suddenDeath
            self.pulmonaryDiseases = patient.pulmonaryDiseases
            self.myocardialInfarction = patient.myocardialInfarction
            self.cardiomyopathies = patient.cardiomyopathies
            self.hypertension = patient.hypertension
            self.highCholesterol = patient.highCholesterol
            self.celiacDisease = patient.celiacDisease
            self.strokeNeurological = patient.strokeNeurological
            self.tumors = patient.tumors
            self.asthmaAllergies = patient.asthmaAllergies
            self.obesity = patient.obesity
            self.geneticDiseases = patient.geneticDiseases
            self.partoNaturale = patient.partoNaturale ?? ""
            self.vaccinazioni = patient.vaccinazioni ?? ""
            self.qualiFarmaci = patient.qualiFarmaci ?? ""
            self.alterazioniEsamiSangue = patient.alterazioniEsamiSangue ?? ""
            self.dieta = patient.dieta ?? ""
            self.fumo = patient.fumo ?? ""
            self.quanteSigarette = patient.quanteSigarette ?? ""
            self.consumoAlcol = patient.consumoAlcol ?? ""
            self.consumoCaffe = patient.consumoCaffe ?? ""
            self.etaMestruazione = patient.etaMestruazione?.decimalValue ?? 0 // Corretto qui
            self.noteAnomalieCiclo = patient.noteAnomalieCiclo ?? ""
            self.gravidanze = patient.gravidanze
        }
    }
    
    func savePatient() {
        let newPatient = Patient(context: context)
        newPatient.name = name
        newPatient.surname = surname
        newPatient.birthDate = birthDate
        newPatient.cf = cf
        newPatient.gender = gender
        newPatient.birthPlace = birthPlace
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
        newPatient.consumoAlcol = consumoAlcol
        newPatient.consumoCaffe = consumoCaffe
        newPatient.etaMestruazione = NSDecimalNumber(decimal: etaMestruazione)
        newPatient.noteAnomalieCiclo = noteAnomalieCiclo
        newPatient.gravidanze = gravidanze
        
        if !qualiFarmaci.isEmpty {
            newPatient.qualiFarmaci = qualiFarmaci
        }
        
        if !alterazioniEsamiSangue.isEmpty {
            newPatient.alterazioniEsamiSangue = alterazioniEsamiSangue
        }
        
        do {
            try context.save()
        } catch {
            print("Failed to save new patient: \(error)")
        }
    }
    
    func loadComuni() {
        let loader = DataLoader()
        loader.loadComuni { [weak self] comuni in
            self?.comuni = comuni
            self?.filteredComuni = comuni
        }
    }
}
