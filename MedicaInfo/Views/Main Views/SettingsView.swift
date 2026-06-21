import SwiftUI

struct SettingsView: View {
    @AppStorage("useDarkMode") private var useDarkMode = false
    @AppStorage("showBirthDate") private var showBirthDate = true
    @AppStorage("showCF") private var showCF = true
    @State private var showingResetAlert = false
    
    var body: some View {
        Form {
            // SEZIONE: ASPETTO
            Section {
                Toggle(isOn: $useDarkMode) {
                    HStack {
                        Image(systemName: useDarkMode ? "moon.fill" : "sun.max.fill")
                            .foregroundColor(useDarkMode ? .purple : .orange)
                            .frame(width: 24)
                        Text("Modalità Scura")
                    }
                }
            } header: {
                Label("Aspetto", systemImage: "paintbrush.fill")
            }
            
            // SEZIONE: LISTA PAZIENTI
            Section {
                Toggle(isOn: $showBirthDate) {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        Text("Mostra Data di Nascita")
                    }
                }
                Toggle(isOn: $showCF) {
                    HStack {
                        Image(systemName: "barcode.viewfinder")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        Text("Mostra Codice Fiscale")
                    }
                }
            } header: {
                Label("Lista Pazienti", systemImage: "list.bullet")
            }
            
            // SEZIONE: INFO APP
            Section {
                HStack {
                    Image(systemName: "apps.iphone")
                        .foregroundColor(.blue)
                        .frame(width: 24)
                    Text("Versione")
                        .fixedSize(horizontal: true, vertical: false)
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(.secondary)
                        .fixedSize()
                }
                HStack {
                    Image(systemName: "swift")
                        .foregroundColor(.orange)
                        .frame(width: 24)
                    Text("SwiftUI + Core Data")
                        .foregroundColor(.secondary)
                }
            } header: {
                Label("App", systemImage: "info.circle")
            }
            
            // SEZIONE: RESET
            Section {
                Button(role: .destructive) {
                    showingResetAlert = true
                } label: {
                    HStack {
                        Image(systemName: "arrow.counterclockwise.circle.fill")
                            .font(.title3)
                        Text("Reset Impostazioni")
                    }
                }
            } header: {
                Label("Reset", systemImage: "exclamationmark.triangle")
            } footer: {
                Text("Ripristina tutte le impostazioni ai valori predefiniti.")
            }
        }
        .navigationTitle("Impostazioni")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
        #endif
        .alert("Reset Impostazioni", isPresented: $showingResetAlert) {
            Button("Annulla", role: .cancel) {}
            Button("Reset", role: .destructive) {
                useDarkMode = false
                showBirthDate = true
                showCF = true
            }
        } message: {
            Text("Tutte le impostazioni verranno ripristinate ai valori predefiniti.")
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
