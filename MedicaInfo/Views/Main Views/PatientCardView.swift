import SwiftUI

struct PatientCardView: View {
    var patient: Patient
    
    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.locale = Locale(identifier: "it_IT")
        return f
    }()
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            // Avatar
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [.blue, .blue.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 52, height: 52)
                
                Text(initials)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(patient.name ?? "")
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text(patient.surname ?? "")
                        .font(.headline)
                        .foregroundColor(.primary)
                }
                
                if let birthDate = patient.birthDate {
                    Text(dateFormatter.string(from: birthDate))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack(spacing: 8) {
                    if let cf = patient.cf, !cf.isEmpty {
                        Label(cf, systemImage: "barcode.viewfinder")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    if let gender = patient.gender, !gender.isEmpty {
                        Image(systemName: gender == "Maschile" ? "mars" : "venus")
                            .font(.caption2)
                            .foregroundColor(gender == "Maschile" ? .blue : .pink)
                    }
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary.opacity(0.5))
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        #if os(iOS)
        .background(Color(.systemBackground))
        #else
        .background(Color(.windowBackgroundColor))
        #endif
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    private var initials: String {
        let nameInitial = (patient.name ?? "").prefix(1).uppercased()
        let surnameInitial = (patient.surname ?? "").prefix(1).uppercased()
        return "\(nameInitial)\(surnameInitial)"
    }
}

#Preview {
    PatientCardView(patient: Patient())
}
