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

    @State private var searchText = ""
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @State private var isSearchVisible = false
    @State private var showDeleteConfirmation = false
    @State private var deleteConfirmationStep = 0
    let onDeleteAllPatients: () -> Void

    private var filteredPatients: [Patient] {
        if searchText.isEmpty { return Array(patients) }
        return patients.filter {
            ($0.name ?? "").localizedCaseInsensitiveContains(searchText)
            || ($0.surname ?? "").localizedCaseInsensitiveContains(searchText)
            || ($0.cf ?? "").localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        ZStack {
            #if os(iOS)
        Color(.systemGroupedBackground).ignoresSafeArea()
        #else
        Color(.controlBackgroundColor).ignoresSafeArea()
        #endif

            VStack(spacing: 0) {
                // Search Bar
                if isSearchVisible {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField("Cerca per nome, cognome o CF...", text: $searchText)
                            .autocorrectionDisabled()
                        if !searchText.isEmpty {
                            Button { searchText = "" } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(10)
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }

                // Content
                if patients.isEmpty {
                    emptyState
                } else if filteredPatients.isEmpty {
                    noResultsState
                } else {
                    patientList
                }

                // Bottom Bar
                bottomBar
            }
            .navigationDestination(for: NSManagedObjectID.self) { objectID in
                let patient = viewContext.object(with: objectID) as! Patient
                PatientDetailView(
                    viewModel: PatientViewModel(patient: patient, context: viewContext),
                    context: viewContext
                )
            }
            .alert(isPresented: $showDeleteConfirmation) { deleteConfirmationAlert }
        }
    }

    // MARK: - Patient List
    private var patientList: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                ForEach(filteredPatients, id: \.objectID) { patient in
                    NavigationLink(value: patient.objectID) {
                        ModernPatientCard(patient: patient)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
    }

    // MARK: - Empty / No Results
    private var emptyState: some View {
        ContentUnavailableView(
            "Nessun Paziente",
            systemImage: "person.3.slash",
            description: Text("Aggiungi il primo paziente\ndalla schermata home.")
        )
    }

    private var noResultsState: some View {
        ContentUnavailableView(
            "Nessun risultato",
            systemImage: "magnifyingglass",
            description: Text("Nessun paziente trovato per \"\(searchText)\"")
        )
    }

    // MARK: - Bottom Bar
    private var bottomBar: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .foregroundColor(.blue)
            }

            Spacer()

            if !patients.isEmpty {
                Button { triggerDelete() } label: {
                    Image(systemName: "trash")
                        .font(.title3)
                        .foregroundColor(.red)
                }
            }

            Spacer()

            Button {
                withAnimation(.smooth) {
                    isSearchVisible.toggle()
                    if !isSearchVisible { searchText = "" }
                }
            } label: {
                Image(systemName: "magnifyingglass")
                    .font(.title3)
                    .foregroundColor(.blue)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 14)
        .background(.ultraThinMaterial)
    }

    // MARK: - Delete Logic
    private func triggerDelete() {
        deleteConfirmationStep = 1
        showDeleteConfirmation = true
    }

    private var deleteConfirmationAlert: Alert {
        switch deleteConfirmationStep {
        case 1: return Alert(
            title: Text("Conferma"),
            message: Text("Cancellare TUTTI i pazienti?"),
            primaryButton: .destructive(Text("Continua")) {
                deleteConfirmationStep += 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { showDeleteConfirmation = true }
            },
            secondaryButton: .cancel { deleteConfirmationStep = 0 }
        )
        case 2: return Alert(
            title: Text("Seconda conferma"),
            message: Text("Sei sicuro? Questa azione è irreversibile."),
            primaryButton: .destructive(Text("Continua")) {
                deleteConfirmationStep += 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { showDeleteConfirmation = true }
            },
            secondaryButton: .cancel { deleteConfirmationStep = 0 }
        )
        case 3: return Alert(
            title: Text("Conferma finale"),
            message: Text("Procedere con la cancellazione di tutti i dati?"),
            primaryButton: .destructive(Text("Sì, cancella tutto")) {
                onDeleteAllPatients()
                deleteConfirmationStep = 0
            },
            secondaryButton: .cancel { deleteConfirmationStep = 0 }
        )
        default: return Alert(title: Text("Errore"))
        }
    }
}

// MARK: - Modern Patient Card
struct ModernPatientCard: View {
    let patient: Patient

    private var initials: String {
        let n = (patient.name ?? "").prefix(1)
        let s = (patient.surname ?? "").prefix(1)
        return "\(n)\(s)".isEmpty ? "?" : "\(n)\(s)".uppercased()
    }

    var body: some View {
        HStack(spacing: 14) {
            // Avatar
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [.blue, .indigo], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 48, height: 48)
                Text(initials)
                    .font(.system(.callout, design: .rounded).weight(.bold))
                    .foregroundColor(.white)
            }

            // Info
            VStack(alignment: .leading, spacing: 2) {
                Text("\(patient.name ?? "") \(patient.surname ?? "")")
                    .font(.body.weight(.semibold))
                    .foregroundColor(.primary)
                    .minimumScaleFactor(0.75)
                if let cf = patient.cf, !cf.isEmpty {
                    Text(cf)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .minimumScaleFactor(0.75)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary.opacity(0.5))
        }
        .padding(14)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
    }
}
