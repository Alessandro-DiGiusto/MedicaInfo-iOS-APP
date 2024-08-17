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

    @Published var comuni: [Comune] = []
    private var cancellables: Set<AnyCancellable> = []
    private var context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
        loadComuni()
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

        do {
            try context.save()
        } catch {
            print("Failed to save new patient: \(error)")
        }
    }

    func loadComuni() {
        let loader = DataLoader()
        self.comuni = loader.loadComuni()
    }
}
