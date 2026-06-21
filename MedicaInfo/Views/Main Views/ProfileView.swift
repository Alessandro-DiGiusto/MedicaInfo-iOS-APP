import SwiftUI

struct ProfileView: View {
    @AppStorage("doctorName") private var doctorName = ""
    @AppStorage("doctorSurname") private var doctorSurname = ""
    @AppStorage("doctorSpecialization") private var doctorSpecialization = ""
    @AppStorage("doctorAddress") private var doctorAddress = ""
    @AppStorage("doctorPhone") private var doctorPhone = ""
    @AppStorage("doctorEmail") private var doctorEmail = ""
    @AppStorage("doctorLicense") private var doctorLicense = ""
    
    @State private var showSaveConfirmation = false
    
    var body: some View {
        Form {
            // SEZIONE: FOTO E NOME
            Section {
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(
                                colors: [.blue, .blue.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 72, height: 72)
                        
                        Text(initials)
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(doctorName.isEmpty && doctorSurname.isEmpty ? "Il tuo Nome" : "\(doctorName) \(doctorSurname)")
                            .font(.title3)
                            .fontWeight(.semibold)
                        if !doctorSpecialization.isEmpty {
                            Text(doctorSpecialization)
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                    }
                }
                .padding(.vertical, 8)
            }
            
            // SEZIONE: DATI ANAGRAFICI
            Section {
                HStack {
                    Image(systemName: "person")
                        .foregroundColor(.blue)
                        .frame(width: 24)
                    TextField("Nome", text: $doctorName)
                            .minimumScaleFactor(0.8)
                }
                HStack {
                    Image(systemName: "person.fill")
                        .foregroundColor(.blue)
                        .frame(width: 24)
                    TextField("Cognome", text: $doctorSurname)
                            .minimumScaleFactor(0.8)
                }
                HStack {
                    Image(systemName: "stethoscope")
                        .foregroundColor(.blue)
                        .frame(width: 24)
                    TextField("Specializzazione", text: $doctorSpecialization)
                }
                HStack {
                    Image(systemName: "number")
                        .foregroundColor(.blue)
                        .frame(width: 24)
                    TextField("Numero Iscrizione Albo", text: $doctorLicense)
                }
            } header: {
                Label("Dati Personali", systemImage: "person.text.rectangle")
            }
            
            // SEZIONE: CONTATTI
            Section {
                HStack {
                    Image(systemName: "house")
                        .foregroundColor(.blue)
                        .frame(width: 24)
                    TextField("Indirizzo Studio", text: $doctorAddress)
                }
                HStack {
                    Image(systemName: "phone")
                        .foregroundColor(.blue)
                        .frame(width: 24)
                    TextField("Telefono", text: $doctorPhone)
                        #if os(iOS)
                        .keyboardType(.phonePad)
                        #endif
                }
                HStack {
                    Image(systemName: "envelope")
                        .foregroundColor(.blue)
                        .frame(width: 24)
                    TextField("Email", text: $doctorEmail)
                        #if os(iOS)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        #endif
                        .disableAutocorrection(true)
                }
            } header: {
                Label("Contatti", systemImage: "building.2")
            } footer: {
                Text("Questi dati vengono salvati localmente sul dispositivo e non vengono condivisi.")
            }
        }
        .navigationTitle("Profilo")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
        #endif
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Salva") {
                    showSaveConfirmation = true
                }
            }
        }
        .alert("✅ Profilo Salvato", isPresented: $showSaveConfirmation) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("I dati del tuo profilo sono stati salvati con successo.")
        }
    }
    
    private var initials: String {
        let first = doctorName.prefix(1).uppercased()
        let last = doctorSurname.prefix(1).uppercased()
        if first.isEmpty && last.isEmpty { return "👤" }
        return "\(first)\(last)"
    }
}

#Preview {
    NavigationStack {
        ProfileView()
    }
}
