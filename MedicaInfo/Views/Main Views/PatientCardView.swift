import SwiftUI
import CoreData

struct PatientCardView: View {
    var patient: Patient

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center, spacing: 12) {
                Image(systemName: "person.crop.circle.fill.badge.checkmark")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                    .foregroundColor(.blue)
                
                Text("\(patient.name ?? "Nome non disponibile") \(patient.surname ?? "Cognome non disponibile")")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
            }
            
            HStack(spacing: 4) {
                Image(systemName: "barcode.viewfinder")
                    .foregroundColor(.blue)
                Text("CF:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(patient.cf ?? "N/A")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(.systemGray6))
                .shadow(color: Color.red.opacity(0.1), radius: 4, x: 0, y: 4)
        )
        .frame(maxWidth: .infinity) // Assicura che la card sia larga quanto possibile
        .padding(.horizontal, 16) // Uguale spazio da sinistra a destra
        .padding(.vertical, 4)
    }
}
