import SwiftUI

struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack {
            TextField("Cerca paziente", text: $text)
                .foregroundColor(.primary)
                .padding(7)
                #if os(iOS)
                .background(Color(.systemGray5))
                #else
                .background(Color(.separatorColor))
                #endif
                .cornerRadius(10)
        }
        .padding(.vertical, 4)
    }
}
