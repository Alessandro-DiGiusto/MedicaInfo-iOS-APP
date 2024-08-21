import SwiftUI
import CoreData

struct DetailView: View {
    @FetchRequest(
        entity: Patient.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Patient.name, ascending: true)]
    ) private var patients: FetchedResults<Patient>
    
    @State private var expandedPatientId: NSManagedObjectID?
    @State private var searchText: String = ""
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    @State private var selectedPatient: Patient?
    @State private var isSearchVisible: Bool = false  // Stato per gestire la visibilità del campo di ricerca
    var onDeleteAllPatients: () -> Void
    
    var body: some View {
        ZStack {
            Color(.systemGray6).edgesIgnoringSafeArea(.all)  // Sfondo uniforme
            
            VStack(spacing: 0) {
                // Barra di ricerca in alto, che appare solo quando isSearchVisible è true
                if isSearchVisible {
                    SearchBar(text: $searchText)
                        .transition(.move(edge: .top))
                        .padding(.horizontal)
                }
                
                // Lista dei pazienti
                List {
                    ForEach(patients.filter { patient in
                        searchText.isEmpty || patient.name?.contains(searchText) == true
                    }) { patient in
                        Button(action: {
                            selectedPatient = patient
                        }) {
                            PatientCardView(patient: patient)  // Usa il design delle card
                        }
                        .buttonStyle(PlainButtonStyle())  // Rimuove lo stile del pulsante per evitare la freccia
                    }
                    .listRowBackground(Color(.systemGray6))  // Sfondo uniforme per le righe
                    .listRowSeparator(.hidden)  // Nasconde la linea di separazione
                }
                .listStyle(PlainListStyle())
                
                // Barra in basso con le icone
                HStack {
                    // Freccia indietro
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.blue)
                            .bold()
                            .font(.system(size: 24))
                    }
                    Spacer()
                    
                    // Pulsante per eliminare tutti i pazienti
                    if !patients.isEmpty {
                        Button(action: {
                            onDeleteAllPatients()
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                                .font(.system(size: 24))
                        }
                    }
                    
                    Spacer()
                    
                    // Pulsante per mostrare la barra di ricerca
                    Button(action: {
                        withAnimation {
                            isSearchVisible.toggle()
                        }
                    }) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.blue)
                            .font(.system(size: 24))
                    }
                }
                .padding()
                .background(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: -5)
            }
            .background(
                selectedPatient.map { patient in
                    NavigationLink(
                        destination: PatientDetailView(patient: patient, dateFormatter: DateFormatter(), context: viewContext)
                            .navigationBarTitleDisplayMode(.inline) // Barra di navigazione inline
                            .navigationBarBackButtonHidden(false),   // Abilita solo il pulsante Back
                        isActive: Binding<Bool>(
                            get: { selectedPatient != nil },
                            set: { if !$0 { selectedPatient = nil } }
                        )
                    ) {
                        EmptyView()
                    }
                }
            )
            
            .navigationBarTitle("")
            .navigationBarHidden(true)  // Nasconde completamente la barra di navigazione predefinita
        }
    }
}
