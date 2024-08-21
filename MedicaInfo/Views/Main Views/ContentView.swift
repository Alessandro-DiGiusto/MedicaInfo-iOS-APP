import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @State private var showAddPatientView = false
    @State private var showPatientListView = false
    @State private var showDeleteConfirmation = false
    @State private var deleteConfirmationStep = 0 // Contatore per le conferme
    
    var body: some View {
        NavigationView {
            ZStack {
                // Sfondo sfumato per un aspetto moderno
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.2), Color.blue.opacity(0.8)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                
                VStack {
                    // Immagine di intestazione
                    Image(systemName: "stethoscope.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .foregroundColor(.white)
                        .shadow(radius: 10)
                        .padding(.top, 50)
                    
                    Text("MedicaInfo")
                        .font(.system(size: 64, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.top, 20)
                    
                    Text("Gestisci facilmente \n le informazioni dei tuoi pazienti")
                        .font(.system(size: 20, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.top, 10)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                    
                    Spacer()
                    Text("Realizzato da alessandrodigiusto.it")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.3))
                        .padding(.top, 10)
                        .padding(.bottom, 30)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                    // Pulsanti di navigazione principali con icone
                    HStack(spacing: 20) {
                        VStack {
                            Button(action: {
                                // Azione per il tasto Impostazioni
                            }) {
                                Image(systemName: "gearshape.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.white)
                            }
                            Text("Settings")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(.white)
                        }
                        
                        VStack {
                            Button(action: {
                                // Azione per il tasto Profilo
                            }) {
                                Image(systemName: "person.crop.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.white)
                            }
                            Text("Profilo")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(.white)
                        }
                        
                        VStack {
                            NavigationLink(destination: AddPatientView()) {
                                Image(systemName: "plus.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 25, height: 25)
                                    .foregroundColor(.white)
                                    .shadow(radius: 5)
                            }
                            Text("Paziente")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(.white)
                        }
                        
                        VStack {
                            NavigationLink(destination: DetailView(onDeleteAllPatients: {
                                handleDeletePatients()
                            })) {
                                Image(systemName: "list.bullet")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.white)
                            }
                            Text("Lista Pazienti")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(.white)
                        }
                        
                        VStack {
                            Button(action: {
                                // Azione per il tasto Info
                            }) {
                                Image(systemName: "info.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.white)
                            }
                            Text("Info")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(.white)
                        }
                    }
                    .padding(.bottom, 25)
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)  // Nasconde la barra di navigazione predefinita
            .alert(isPresented: $showDeleteConfirmation) {
                getDeleteConfirmationAlert()
            }
        }
    }
    
    private func getDeleteConfirmationAlert() -> Alert {
        var alertTitle = "Errore"
        var alertMessage = "Si è verificato un errore."
        var primaryButton: Alert.Button = .default(Text("OK"))
        var secondaryButton: Alert.Button = .cancel()
        
        switch deleteConfirmationStep {
        case 1:
            alertTitle = "Conferma Cancellazione"
            alertMessage = "Sei sicuro di voler cancellare tutti i pazienti?"
            primaryButton = .destructive(Text("Conferma")) {
                deleteConfirmationStep += 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    showDeleteConfirmation = true
                }
            }
            secondaryButton = .cancel {
                deleteConfirmationStep = 0
            }
        case 2:
            alertTitle = "Conferma Cancellazione"
            alertMessage = "Questa è la seconda conferma. Sei sicuro di voler cancellare tutti i pazienti?"
            primaryButton = .destructive(Text("Conferma")) {
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
            alertMessage = "Questa è la terza e ultima conferma. Sei sicuro?"
            primaryButton = .destructive(Text("Conferma")) {
                deleteAllPatients()
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
    
    // Funzione che gestisce la cancellazione dei pazienti con conferme multiple
    private func handleDeletePatients() {
        deleteConfirmationStep = 1
        showDeleteConfirmation = true
    }
    
    // Funzione per cancellare tutti i pazienti
    private func deleteAllPatients() {
        // Crea una richiesta di recupero di tutti i pazienti
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Patient.fetchRequest()
        
        // Crea un batch delete request per rimuovere tutti i pazienti
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            // Esegui il delete request
            try viewContext.execute(deleteRequest)
            
            // Salva il contesto per rendere permanenti le modifiche
            try viewContext.save()
            
            print("Tutti i pazienti sono stati cancellati.")
        } catch {
            // Gestisci l'errore
            print("Errore durante la cancellazione dei pazienti: \(error)")
        }
    }
}

#Preview {
    ContentView()
}
