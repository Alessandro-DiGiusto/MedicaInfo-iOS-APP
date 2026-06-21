import SwiftUI
import CoreData

// MARK: - Professional Home Screen
struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @State private var showDeleteConfirmation = false
    @State private var deleteConfirmationStep = 0
    @State private var showSuccessOverlay = false

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient
                content
            }
            .navigationTitle("")
            #if os(iOS)
            .navigationBarHidden(true)
            #endif
            .navigationDestination(for: String.self) { value in
                switch value {
                case "addPatient": AddPatientView()
                case "dietPlan": DietPlanView()
                case "patientList": DetailView(onDeleteAllPatients: handleDeletePatients)
                case "settings": SettingsView()
                case "profile": ProfileView()
                case "info": InfoView()
                default: EmptyView()
                }
            }
            .alert(isPresented: $showDeleteConfirmation) { deleteAlert }
            .overlay(successOverlayView)
        }
    }

    // MARK: - Background
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [
                .blue.opacity(0.15),
                .blue.opacity(0.45),
                .indigo.opacity(0.3)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    // MARK: - Content
    private var content: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 32) {
                headerSection
                quickActionsGrid
                footerSection
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 60)
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "stethoscope.circle.fill")
                .font(.system(size: 72))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.15), radius: 12, y: 4)

            Text("MedicaInfo")
                .font(.system(size: 42, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Text("Gestione professionale dei pazienti")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .padding(.top, 20)
    }

    // MARK: - Quick Actions Grid
    private var quickActionsGrid: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ActionTile(
                icon: "plus.circle.fill",
                title: "Paziente",
                subtitle: "Nuovo",
                color: .blue,
                destination: "addPatient"
            )
            ActionTile(
                icon: "fork.knife.circle.fill",
                title: "Dieta",
                subtitle: "Piano alimentare",
                color: .orange,
                destination: "dietPlan"
            )
            ActionTile(
                icon: "list.bullet.rectangle",
                title: "Lista",
                subtitle: "Pazienti",
                color: .green,
                destination: "patientList"
            )
            ActionTile(
                icon: "person.crop.circle",
                title: "Profilo",
                subtitle: "Medico",
                color: .purple,
                destination: "profile"
            )
            ActionTile(
                icon: "gearshape",
                title: "Settings",
                subtitle: "Impostazioni",
                color: .gray,
                destination: "settings"
            )
            ActionTile(
                icon: "info.circle",
                title: "Info",
                subtitle: "App",
                color: .teal,
                destination: "info"
            )
        }
    }

    // MARK: - Footer
    private var footerSection: some View {
        VStack(spacing: 8) {
            Text("Realizzato da")
                .font(.caption)
                .foregroundColor(.white.opacity(0.5))
            Link("alessandrodigiusto.it", destination: URL(string: "https://alessandrodigiusto.it")!)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))

            if !patientsExist {
                Button(role: .destructive) {
                    handleDeletePatients()
                } label: {
                    Label("Elimina tutti i pazienti", systemImage: "trash")
                        .font(.caption)
                        .foregroundColor(.red.opacity(0.7))
                }
                .buttonStyle(.plain)
                .padding(.top, 12)
            }
        }
    }

    // MARK: - Helpers
    private var patientsExist: Bool {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Patient")
        request.fetchLimit = 1
        return (try? viewContext.count(for: request)) ?? 0 > 0
    }

    // MARK: - Delete Alert
    private var deleteAlert: Alert {
        switch deleteConfirmationStep {
        case 1:
            return Alert(
                title: Text("Conferma Cancellazione"),
                message: Text("Sei sicuro di voler cancellare TUTTI i pazienti?\n\nQuesta azione non può essere annullata."),
                primaryButton: .destructive(Text("Continua")) {
                    deleteConfirmationStep += 1
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        showDeleteConfirmation = true
                    }
                },
                secondaryButton: .cancel { deleteConfirmationStep = 0 }
            )
        case 2:
            return Alert(
                title: Text("Seconda Conferma"),
                message: Text("Stai per cancellare definitivamente tutti i dati. Sei sicuro?"),
                primaryButton: .destructive(Text("Continua")) {
                    deleteConfirmationStep += 1
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        showDeleteConfirmation = true
                    }
                },
                secondaryButton: .cancel { deleteConfirmationStep = 0 }
            )
        case 3:
            return Alert(
                title: Text("Conferma Finale"),
                message: Text("Ultima possibilità. Procedere?"),
                primaryButton: .destructive(Text("Sì, cancella tutto")) {
                    deleteAllPatients()
                    deleteConfirmationStep = 0
                },
                secondaryButton: .cancel { deleteConfirmationStep = 0 }
            )
        default:
            return Alert(title: Text("Errore"), message: Text("Operazione annullata."))
        }
    }

    private func handleDeletePatients() {
        deleteConfirmationStep = 1
        showDeleteConfirmation = true
    }

    private func deleteAllPatients() {
        let request: NSFetchRequest<NSFetchRequestResult> = Patient.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
        do {
            try viewContext.execute(deleteRequest)
            try viewContext.save()
            withAnimation { showSuccessOverlay = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation { showSuccessOverlay = false }
            }
        } catch {
            print("Errore cancellazione: \(error)")
        }
    }

    private var successOverlayView: some View {
        Group {
            if showSuccessOverlay {
                VStack {
                    Spacer()
                    HStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                        Text("Cancellati!")
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    .background(.green.gradient)
                    .clipShape(Capsule())
                    .shadow(color: .green.opacity(0.3), radius: 12, y: 6)
                    .padding(.bottom, 40)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
    }
}

// MARK: - Action Tile Component
struct ActionTile: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let destination: String

    var body: some View {
        NavigationLink(value: destination) {
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(color)
                    .frame(height: 28)

                Text(title)
                    .font(.callout)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)

                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .padding(.horizontal, 8)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ContentView()
}
