import SwiftUI
import CoreData

struct AddNoteView: View {
    let patientId: NSManagedObjectID
    let conditions: String?
    let onDismiss: () -> Void

    @State private var noteText: String = ""

    var body: some View {
        NavigationStack {
            VStack {
                Text("Aggiungi Nota")
                    .font(.title)
                    .padding()
                    .background(.red)

                TextEditor(text: $noteText)
                    .frame(minHeight: 200)
                    .padding()

                Button("Salva") {
                    onDismiss()
                }
                .padding()
                .disabled(noteText.isEmpty)
            }
            .navigationTitle("Aggiungi Nota")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annulla") {
                        onDismiss()
                    }
                }
            }
        }
    }
}
