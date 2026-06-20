import SwiftUI
import CoreData

struct DetailView: View {
    @FetchRequest(
        entity: Patient.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Patient.surname, ascending: true),
            NSSortDescriptor(keyPath: \Patient.name, ascending: true)
        ]
    ) private var patients: FetchedResults<Patient>
    
    @State private var searchText: String = ""
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    @State private var isSearchVisible: Bool = false
    @State private var selectedPatientID: NSManagedObjectID?
    @State private var showDeleteConfirmation = false
    @State private var deleteConfirmationStep = 0
    var onDeleteAllPatients: () -> Void
    
    private var filteredPatients: [Patient] {
        if searchText.isEmpty {
            return Array(patients)
        }
        return patients.filter { patient in
            let nameMatch = (patient.name ?? "").localizedCaseInsensitiveContains(searchText)
            let surnameMatch = (patient.surname ?? "").localizedCaseInsensitiveContains(searchText)
            let cfMatch = (patient.cf ?? "").localizedCaseInsensitiveContains(searchText)
            return nameMatch || surnameMatch || cfMatch
        }
    }
    
    var body: some View {
        ZStack {
            #if os(iOS)
        Color(.systemGray6).edgesIgnoringSafeArea(.all)
        #else
        Color(.controlBackgroundColor).edgesIgnoringSafeArea(.all)
        #endif
            
            VStack(spacing: 0) {
                // Barra di ricerca
                if isSearchVisible {
                    SearchBar(text: $searchText)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .padding(.horizontal)
                        .padding(.top, 4)
                }
                
                if patients.isEmpty && !isSearchVisible {
                    // Stato vuoto
                    emptyStateView
                } else if filteredPatients.isEmpty && !searchText.isEmpty {
                    // Nessun risultato per la ricerca
                    noResultsView
                } else {
                    // Lista dei pazienti
                    List {
                        ForEach(filteredPatients, id: \.objectID) { patient in
                            NavigationLink(value: patient.objectID) {
                                PatientCardView(patient: patient)
                            }
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                        }
                    }
                    .listStyle(PlainListStyle())
                }
                
                // Bottom bar
                bottomBar
            }
            .navigationDestination(for: NSManagedObjectID.self) { objectID in
                let patient = viewContext.object(with: objectID) as! Patient
                PatientDetailView(
                    viewModel: PatientViewModel(patient: patient, context: viewContext),
                    context: viewContext
                )
                #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
                #endif
            }
            .alert(isPresented: $showDeleteConfirmation) {
                deleteConfirmationAlert
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "person.3.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(.blue.opacity(0.4))
            
            Text("Nessun Paziente")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            
            Text("Aggiungi il primo paziente\ntoccando il pulsante + nella home")
                .font(.body)
                .foregroundColor(.secondary.opacity(0.7))
                .multilineTextAlignment(.center)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
    
    private var noResultsView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "magnifyingglass")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .foregroundColor(.secondary.opacity(0.4))
            
            Text("Nessun risultato")
                .font(.title3)
                .foregroundColor(.secondary)
            
            Text("Nessun paziente trovato per \"\(searchText)\"")
                .font(.body)
                .foregroundColor(.secondary.opacity(0.7))
                .multilineTextAlignment(.center)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Bottom Bar
    
    private var bottomBar: some View {
        HStack {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(.blue)
                    .bold()
                    .font(.system(size: 22))
            }
            
            Spacer()
            
            if !patients.isEmpty {
                Button(action: {
                    deleteConfirmationStep = 1
                    showDeleteConfirmation = true
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .font(.system(size: 22))
                }
            }
            
            Spacer()
            
            Button(action: {
                withAnimation(.easeInOut(duration: 0.25)) {
                    isSearchVisible.toggle()
                    if !isSearchVisible {
                        searchText = ""
                    }
                }
            }) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.blue)
                    .font(.system(size: 22))
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
    }
    
    // MARK: - Delete Confirmation Alert
    
    private var deleteConfirmationAlert: Alert {
        var alertTitle = "Errore"
        var alertMessage = "Si è verificato un errore."
        var primaryButton: Alert.Button = .default(Text("OK"))
        var secondaryButton: Alert.Button = .cancel()
        
        switch deleteConfirmationStep {
        case 1:
            alertTitle = "Conferma Cancellazione"
            alertMessage = "Sei sicuro di voler cancellare TUTTI i pazienti?\n\nQuesta azione non può essere annullata."
            primaryButton = .destructive(Text("Continua")) {
                deleteConfirmationStep += 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    showDeleteConfirmation = true
                }
            }
            secondaryButton = .cancel {
                deleteConfirmationStep = 0
            }
        case 2:
            alertTitle = "Seconda Conferma"
            alertMessage = "Stai per cancellare definitivamente tutti i dati dei pazienti. Sei sicuro?"
            primaryButton = .destructive(Text("Continua")) {
                deleteConfirmationStep += 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    showDeleteConfirmation = true
                }
            }
            secondaryButton = .cancel {
                deleteConfirmationStep = 0
            }
        case 3:
            alertTitle = "Conferma Finale"
            alertMessage = "Ultima possibilità. Vuoi davvero cancellare tutto?"
            primaryButton = .destructive(Text("Sì, cancella tutto")) {
                onDeleteAllPatients()
                deleteConfirmationStep = 0
            }
            secondaryButton = .cancel {
                deleteConfirmationStep = 0
            }
        default:
            break
        }
        
        return Alert(title: Text(alertTitle), message: Text(alertMessage), primaryButton: primaryButton, secondaryButton: secondaryButton)
    }
}
