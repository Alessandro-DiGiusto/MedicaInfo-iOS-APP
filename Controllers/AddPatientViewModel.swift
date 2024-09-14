import Foundation
import CoreData
import Combine

class AddPatientViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var surname: String = ""
    @Published var birthDate: Date = Date() // Default a oggi
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
    @Published var dataUltimaMestruazione: Date = Date()
    @Published var noteAnomalieCiclo: String = ""
    @Published var gravidanze: Bool = false
    // Proprietà per la dieta
    @Published var dietaVaria: Bool = false
    @Published var dietaVegana: Bool = false
    @Published var dietaVegetariana: Bool = false
    @Published var dietaSpeciale: Bool = false
    @Published var scelta: String = ""
    
    @Published var comuni: [Comune] = []
    @Published var filteredComuni: [Comune] = []
    
    private var cancellables: Set<AnyCancellable> = []
    private var context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
        loadComuni()
        
        // Filtra i comuni quando cambia il campo di testo birthPlace
        $birthPlace
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .map { searchTerm in
                self.comuni.filter { $0.nome.lowercased().contains(searchTerm.lowercased()) }
            }
            .assign(to: &$filteredComuni)
    }
    
    func savePatient() {
        let newPatient = Patient(context: context)
        newPatient.name = name
        newPatient.surname = surname
        //newPatient.birthDate = birthDate
        newPatient.cf = cf
        newPatient.gender = gender
        newPatient.birthPlace = birthPlace
        newPatient.birthDate = birthDate  // Usa la data di nascita selezionata
        print("Data di nascita salvata: \(newPatient.birthDate ?? Date())")
        print("Selected Birth Date: \(birthDate)")
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
        //newPatient.consumoAlcol = consumoAlcol
        newPatient.consumoCaffe = consumoCaffe
        
        if scelta.isEmpty {
            newPatient.consumoAlcol = consumoAlcol
        } else {
            newPatient.consumoAlcol = scelta
        }
        
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
        
        print("Saving patient with the following details:")
        print("Name: \(newPatient.name ?? "N/A")")
        print("Surname: \(newPatient.surname ?? "N/A")")
        print("Birth Date: \(newPatient.birthDate ?? Date())")
        print("Codice Fiscale: \(newPatient.cf ?? "N/A")")
        print("Gender: \(newPatient.gender ?? "N/A")")
        print("Birth Place: \(newPatient.birthPlace ?? "N/A")")
        print("Residence Address: \(newPatient.residenceAddress ?? "N/A")")
        print("Telephone: \(newPatient.tel ?? "N/A")")
        print("Sport Anamnesis: \(newPatient.sportAnamnesis)")
        print("Required Sport: \(newPatient.requiredSport ?? "N/A")")
        print("Years of Practice: \(newPatient.yearsOfPractice)")
        print("Weekly Hours: \(newPatient.weeklyHours)")
        print("Practices Other Sports: \(newPatient.practicesOtherSports)")
        print("Other Sports Details: \(newPatient.otherSportsDetails ?? "N/A")")
        print("Past Sports: \(newPatient.pastSports ?? "N/A")")
        print("Diabetes Mellitus: \(newPatient.diabetesMellitus)")
        print("Heart Disease: \(newPatient.heartDisease)")
        print("Thyroid Diseases: \(newPatient.thyroidDiseases)")
        print("Sudden Death: \(newPatient.suddenDeath)")
        print("Pulmonary Diseases: \(newPatient.pulmonaryDiseases)")
        print("Myocardial Infarction: \(newPatient.myocardialInfarction)")
        print("Cardiomyopathies: \(newPatient.cardiomyopathies)")
        print("Hypertension: \(newPatient.hypertension)")
        print("High Cholesterol: \(newPatient.highCholesterol)")
        print("Celiac Disease: \(newPatient.celiacDisease)")
        print("Stroke Neurological: \(newPatient.strokeNeurological)")
        print("Tumors: \(newPatient.tumors)")
        print("Asthma/Allergies: \(newPatient.asthmaAllergies)")
        print("Obesity: \(newPatient.obesity)")
        print("Genetic Diseases: \(newPatient.geneticDiseases)")
        print("Parto Naturale: \(newPatient.partoNaturale ?? "N/A")")
        print("Vaccinazioni: \(newPatient.vaccinazioni ?? "N/A")")
        print("Dieta: \(newPatient.dieta ?? "N/A")")
        print("Fumo: \(newPatient.fumo ?? "N/A")")
        print("Quante Sigarette: \(newPatient.quanteSigarette ?? "N/A")")
        print("Consumo Alcol: \(newPatient.consumoAlcol ?? "N/A")")
        print("Consumo Caffe: \(newPatient.consumoCaffe ?? "N/A")")
        print("Eta Mestruazione: \(newPatient.etaMestruazione ?? 0)")
        print("Note Anomalie Ciclo: \(newPatient.noteAnomalieCiclo ?? "N/A")")
        print("Gravidanze: \(newPatient.gravidanze)")
        print("Quali Farmaci: \(newPatient.qualiFarmaci ?? "N/A")")
        print("Alterazioni Esami Sangue: \(newPatient.alterazioniEsamiSangue ?? "N/A")")
        
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
