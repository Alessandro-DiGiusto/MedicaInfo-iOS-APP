import SwiftUI

struct InfoView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "stethoscope.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundStyle(.linearGradient(
                            colors: [.blue, .blue.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                    
                    Text("MedicaInfo")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Versione 1.0.0")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)
                
                // Badge sviluppatore
                VStack(spacing: 8) {
                    Image(systemName: "applelogo")
                        .font(.title2)
                        .foregroundColor(.blue)
                    Text("Sviluppato con ❤️ da")
                        .font(.body)
                        .foregroundColor(.secondary)
                    Text("Alessandro Di Giusto")
                        .font(.title3)
                        .fontWeight(.semibold)
                    Link("alessandrodigiusto.it", destination: URL(string: "https://alessandrodigiusto.it")!)
                        .font(.body)
                }
                .padding()
                .frame(maxWidth: .infinity)
                #if os(iOS)
                .background(Color(.systemGray6))
                #else
                .background(Color(.controlBackgroundColor))
                #endif
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)
                
                // Feature Cards
                VStack(alignment: .leading, spacing: 12) {
                    Text("Funzionalità")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    FeatureCard(
                        icon: "person.text.rectangle",
                        iconColor: .blue,
                        title: "Gestione Pazienti",
                        description: "Crea, visualizza e gestisci le schede dei tuoi pazienti con tutte le informazioni anagrafiche e cliniche."
                    )
                    
                    FeatureCard(
                        icon: "heart.text.square",
                        iconColor: .red,
                        title: "Anamnesi Completa",
                        description: "Raccogli anamnesi sportiva, condizioni mediche e anamnesi fisiologica in modo strutturato."
                    )
                    
                    FeatureCard(
                        icon: "doc.richtext",
                        iconColor: .orange,
                        title: "Caricamento PDF",
                        description: "Allega referti ECG e altri documenti PDF direttamente alla scheda del paziente."
                    )
                    
                    FeatureCard(
                        icon: "magnifyingglass",
                        iconColor: .green,
                        title: "Ricerca Rapida",
                        description: "Cerca i pazienti per nome, cognome o codice fiscale."
                    )
                }
                
                // Footer
                VStack(spacing: 4) {
                    Text("© 2024 Alessandro Di Giusto")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("Tutti i dati sono salvati localmente sul dispositivo.")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 12)
                .padding(.bottom, 30)
            }
        }
        #if os(iOS)
        .background(Color(.systemGroupedBackground))
        #else
        .background(Color(.controlBackgroundColor))
        #endif
        .navigationTitle("Info")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.large)
        #endif
    }
}

// MARK: - Feature Card Component

struct FeatureCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .resizable()
                .scaledToFit()
                .frame(width: 32, height: 32)
                .foregroundColor(iconColor)
                .padding(12)
                .background(iconColor.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding()
        #if os(iOS)
                .background(Color(.systemBackground))
                #else
                .background(Color(.windowBackgroundColor))
                #endif
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
        .padding(.horizontal)
    }
}

#Preview {
    NavigationStack {
        InfoView()
    }
}
