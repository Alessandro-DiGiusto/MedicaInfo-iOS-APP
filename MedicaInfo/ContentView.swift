import SwiftUI

struct ContentView: View {
    @State private var showAddPatientView = false
    @State private var showPatientListView = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack {
                    Spacer()
                    Text("Benvenuti")
                        .font(.largeTitle)
                        .bold()
                    Spacer()
                }
            }
            .navigationTitle("MedicaInfo")
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    HStack {
                        Button(action: {
                            // Azione per il tasto Impostazioni
                        }) {
                            Image(systemName: "gearshape.fill")
                        }
                        .padding()
                        
                        Button(action: {
                            // Azione per il tasto Profilo
                        }) {
                            Image(systemName: "person.fill")
                        }
                        .padding()
                        
                        Button(action: {
                            showAddPatientView.toggle()
                        }) {
                            Image(systemName: "plus.circle.fill")
                        }
                        .padding()
                        
                        Button(action: {
                            showPatientListView.toggle()
                        }) {
                            Image(systemName: "list.bullet")
                        }
                        .padding()
                        
                        Button(action: {
                            // Azione per il tasto Info
                        }) {
                            Image(systemName: "info.circle.fill")
                        }
                        .padding()
                    }
                }
            }
            .sheet(isPresented: $showAddPatientView) {
                AddPatientView()
            }
            .sheet(isPresented: $showPatientListView) {
                DetailView(onDeleteAllPatients: {
                    // Implementa l'azione per eliminare tutti i pazienti qui
                })
            }
        }
    }
}

#Preview {
    ContentView()
}
