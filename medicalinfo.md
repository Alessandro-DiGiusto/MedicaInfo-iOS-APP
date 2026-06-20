# MedicaInfo — Descrizione tecnica completa per AI

> **Attenzione**: questo file è scritto per essere letto da AI (Gemini, ChatGPT, Claude, DeepSeek, ecc.), non da umani. Contiene la descrizione tecnica dell'app per permettere a qualsiasi modello di comprendere il progetto, suggerire modifiche, scrivere codice o fare debug.

---

## Panoramica

**MedicaInfo** è un'app iOS nativa scritta in **SwiftUI** con **Core Data** per la persistenza. Destinata a medici, serve a gestire le informazioni anagrafiche, l'anamnesi sportiva, le condizioni mediche e l'anamnesi fisiologica dei pazienti. Include anche il caricamento/visualizzazione di PDF (referti ECG) e note testuali.

- **Target**: iOS 17.2+, iPadOS 17.2+, macOS 14.0+
- **Architettura**: MVVM (Model-View-ViewModel)
- **Persistenza**: Core Data (`MedicalDataModel.xcdatamodeld`)
- **Linguaggio**: Swift 5.0
- **UI Framework**: SwiftUI
- **File aggiuntivi**: JSON statico per autocomplete comuni italiani

---

## Struttura delle directory

```
MedicaInfo/
├── MedicaInfoApp.swift            # Entry point (@main)
├── AppDelegate.swift              # UIApplicationDelegate (obsoleto, ma presente)
├── MedicaInfo.entitlements        # Entitlements (Hardened Runtime, ecc.)
├── MedicaInfo-Bridging-Header.h   # Bridging header (vuoto)
├── Assets.xcassets/               # Asset catalog (icone, colori, background)
│   ├── AccentColor.colorset/
│   ├── AppIcon.appiconset/
│   └── backgroundGLASS.imageset/
├── Models/
│   ├── Comune.swift               # Struct Codable per JSON comuni
│   ├── Item.swift                 # Modello SwiftData (inutilizzato, residuo)
│   ├── comuni.json                # JSON con 7904 comuni italiani
│   └── MedicalDataModel.xcdatamodeld/  # Core Data model
├── Controllers/
│   ├── DataLoader.swift           # Carica comuni.json dal bundle
│   ├── PersistenceController.swift # Singleton Core Data stack
│   ├── PatientViewModel.swift     # ViewModel per dettaglio paziente
│   └── AddPatientViewModel.swift  # ViewModel per aggiunta paziente
├── Extensions/
│   └── UIApplication+Extensions.swift  # endEditing() per dismiss tastiera
└── Views/
    ├── Main Views/
    │   ├── ContentView.swift       # Home screen
    │   ├── AddPatientView.swift    # Form aggiunta paziente
    │   ├── DetailView.swift        # Lista pazienti + search
    │   ├── PatientDetailView.swift # Dettaglio singolo paziente
    │   ├── PatientCardView.swift   # Card paziente (lista)
    │   ├── AnamnesiView.swift      # Form anamnesi (parziale/inutilizzato)
    │   └── AddNoteView.swift       # Aggiunta nota (parziale/inutilizzato)
    ├── Components/
    │   ├── SearchBar.swift         # Barra di ricerca
    │   ├── SectionCard.swift       # Card sezione riutilizzabile
    │   ├── DetailRow.swift         # Riga titolo:valore
    │   ├── MedicalConditionRow.swift # Riga condizione medica
    │   ├── DietaButton.swift       # Pulsante opzione dieta/fumo/alcol
    │   └── MedicalPatient.swift    # Struct MedicalPatient (residuo/inutilizzato)
    └── PDF/
        └── PDFKitRepresentedView.swift # UIViewRepresentable per PDFKit
```

---

## Flusso dell'app

### 1. Avvio (`MedicaInfoApp.swift`)
- Crea un `PersistenceController.shared` (singleton Core Data)
- Inietta il `viewContext` nell'ambiente SwiftUI
- Mostra `ContentView()`

**Nota**: c'è una funzione commentata `init()` che chiama `deleteAllPatients()` all'avvio — è disabilitata ma disponibile.

### 2. Home (`ContentView.swift`)
- Schermata con sfondo gradiente blu
- Icona stetoscopio + titolo "MedicaInfo"
- Tagline: "Gestisci facilmente le informazioni dei tuoi pazienti"
- Footer: "Realizzato da alessandrodigiusto.it"
- **Bottoni navigazione** (in basso):
  - Settings (gearshape) — **non implementato**, azione vuota
  - Profilo (person) — **non implementato**, azione vuota
  - **Paziente (+)**: NavigationLink → `AddPatientView()`
  - **Lista Pazienti**: NavigationLink → `DetailView()`
  - Info (info) — **non implementato**, azione vuota
- Sistema di **conferma cancellazione** a 3 step (alert annidati) per eliminare tutti i pazienti
- Overlay di successo verde "✅ Cancellati!" dopo la cancellazione

### 3. Aggiunta Paziente (`AddPatientView.swift`)

#### ViewModel: `AddPatientViewModel`
- `@Published` properties per tutti i campi del form
- Carica i comuni all'init tramite `DataLoader`
- Filtra i comuni in base alla digitazione (debounce 300ms) → autocomplete nel campo "Comune di Nascita"
- `savePatient()` crea un'istanza `Patient` Core Data e popola tutti gli attributi

#### Form (sezioni):
1. **Dati Personali**
   - Nome, Cognome
   - Data di nascita (`DatePicker`)
   - Codice Fiscale (convertito in uppercase)
   - Sesso (Picker segmentato: Maschile/Femminile)
   - Comune di Nascita (TextField + autocomplete da JSON comuni)
   - Indirizzo di Residenza
   - Telefono (keyboard `.phonePad`)

2. **Anamnesi Sportiva** (toggle per attivare)
   - Sport richiesto
   - Anni di pratica (TextField numerico)
   - Ore settimanali (TextField numerico)
   - Pratica altri sport (toggle + dettagli)
   - Sport praticati in passato

3. **Condizioni Mediche** (toggle multipli)
   - Diabete Mellito, Malattie di Cuore, Malattie Tiroidee, Morte Improvvisa, Malattie Polmonari, Infarto del Miocardio, Cardiomiopatie, Ipertensione, Colesterolo Alto, Celiachia, Ictus/Malattie Neurologiche, Tumori, Asma/Allergie, Obesità, Malattie Genetiche

4. **Anamnesi Fisiologica**
   - Parto naturale (NO/SI/Altro con TextField)
   - Vaccinazioni (NON LO SO/NO/SI)
   - Assume regolarmente farmaci/integratori? (toggle + TextField)
   - Esami del sangue ultimo anno (toggle + TextField)
   - Dieta (pulsanti: Varia/Vegana/Vegetariana/Speciale con TextField)
   - Fumatore (pulsanti: NO/EX/SI + quantità)
   - Beve alcolici (pulsanti: NO/SI + quantità)
   - Consuma caffè (pulsanti: NO/SI + quantità)

5. **Salva** — Bottone in fondo che chiama `viewModel.savePatient()`, mostra overlay "✅ Salvato" e poi torna indietro

### 4. Lista Pazienti (`DetailView.swift`)
- `@FetchRequest` ordinata per nome ascendente
- `SearchBar` toggleabile (icona lente)
- Lista di `PatientCardView` (icona + nome/cognome)
- Tap su card → naviga a `PatientDetailView` tramite `NavigationLink` programmatico
- Bottom bar: freccia indietro, trash (elimina tutti), lente (cerca)
- La cancellazione di tutti i pazienti è gestita tramite callback a `ContentView`

### 5. Dettaglio Paziente (`PatientDetailView.swift`)

#### ViewModel: `PatientViewModel`
- `@Published var patient: Patient` e `noteText`
- `pdfFileURL: URL?` — calcolato da `patient.pdfFilePath`
- `savePDF(url:)` — copia il PDF da URL esterno (security-scoped) nella directory Documents dell'app, salva il path in Core Data
- `removePDF()` — elimina il file dal filesystem e azzora il path in Core Data
- `saveNote()` — salva la nota su Core Data

#### Vista (sezioni in ScrollView):
1. **Anagrafica** — Nome Completo, Data di Nascita, Indirizzo, Codice Fiscale, Sesso, Telefono
2. **Anamnesi Sportiva** — Sport richiesto, anni, ore, altri sport, sport passati
3. **Condizioni Mediche** — Mostra solo quelle presenti (altrimenti "Nessuna condizione medica presente")
4. **Anamnesi Fisiologica** — Parto, Vaccinazioni, Dieta, Fumo, Alcol, Caffè, Età mestruazione, Anomalie ciclo, Gravidanze, Farmaci, Alterazioni esami sangue
5. **Carica E.C.G.** — Bottone "Aggiungi" → `fileImporter` per PDF → salva. Bottone "Visualizza" → sheet con `PDFViewer`. Bottone "Rimuovi" → cancella PDF.
6. **Nota** — Mostra la nota esistente, TextField per nuova nota, Bottone "Salva Nota"

---

## Core Data Model

### Entità: `Patient`

**Attributi booleani** (tutti `optional`, `usesScalarValueType=YES`):
- `sportAnamnesis`, `practicesOtherSports`
- `diabetesMellitus`, `heartDisease`, `thyroidDiseases`, `suddenDeath`, `pulmonaryDiseases`, `myocardialInfarction`, `cardiomyopathies`, `hypertension`, `highCholesterol`, `celiacDisease`, `strokeNeurological`, `tumors`, `asthmaAllergies`, `obesity`, `geneticDiseases`
- `gravidanze`, `previousNonEligibility`

**Attributi stringa** (tutti `optional`):
- `name`, `surname`, `cf`, `gender`, `birthPlace`, `residenceAddress`, `tel`
- `requiredSport`, `otherSportsDetails`, `pastSports`
- `partoNaturale`, `vaccinazioni`, `dieta`, `fumo`, `quanteSigarette`, `consumoAlcol`, `consumoCaffe`
- `qualiFarmaci`, `alterazioniEsamiSangue`, `noteAnomalieCiclo`
- `nota`, `pdfFilePath`, `conditions`

**Attributi data/numero**:
- `birthDate` (Date, optional)
- `etaMestruazione` (Decimal, default 0)
- `yearsOfPractice` (Integer 16, default 0)
- `weeklyHours` (Integer 16, default 0)

---

## Comuni JSON

- File: `Models/comuni.json` (198 KB)
- 7904 comuni italiani
- Formato: array di oggetti `{"nome": "Nome Comune"}`
- Decodificato in `[Comune]` (struct `Codable` con `Hashable` + `Identifiable`)
- Usato per autocomplete nel campo "Comune di Nascita" in `AddPatientView`

---

## Componenti UI riutilizzabili

| Componente | File | Descrizione |
|---|---|---|
| `SectionCard` | `Components/SectionCard.swift` | Card con titolo e contenuto generico (sfondo grigio, shadow) |
| `DetailRow` | `Components/DetailRow.swift` | Riga `Titolo: Valore` con allineamento |
| `MedicalConditionRow` | `Components/MedicalConditionRow.swift` | Wrapper di `DetailRow` per condizioni mediche |
| `SearchBar` | `Components/SearchBar.swift` | TextField con stile search |
| `DietaButton` | `Components/DietaButton.swift` | Pulsante con cerchio di selezione (checkmark/circle) |
| `ToggleGroupView` | dentro `AddPatientView.swift` | Gruppo di bottoni per opzioni mutuamente esclusive |
| `CheckboxField` | dentro `AddPatientView.swift` | Checkbox con label (dx o sx) |
| `PDFKitRepresentedView` | `PDF/PDFKitRepresentedView.swift` | Wrapper `UIViewRepresentable` per `PDFView` |

---

## ViewModel / Controller

### `DataLoader`
- Carica `comuni.json` dal bundle su background thread
- Decodifica in `[Comune]`
- Completion handler sul main thread

### `PersistenceController`
- Singleton `shared`
- `NSPersistentContainer(name: "MedicalDataModel")`
- Carica gli store all'init

### `PatientViewModel`
- ObservableObject per la schermata dettaglio paziente
- Gestisce: salvataggio nota, upload/rimozione PDF

### `AddPatientViewModel`
- ObservableObject per il form aggiunta paziente
- Gestisce: autocomplete comuni (debounce 300ms + Combine), salvataggio nuovo paziente su Core Data

---

## Pattern e dettagli implementativi

- **Dismiss tastiera**: `UIApplication.shared.endEditing()` esteso via `UIApplication+Extensions`
- **DateFormatter**: Stile `.long` per visualizzare date nei dettagli
- **Security-scoped resources**: Il `fileImporter` usa `startAccessingSecurityScopedResource()` prima di copiare il PDF
- **Batch delete**: Usato sia in `ContentView.deleteAllPatients()` che in `MedicaInfoApp.deleteAllPatients()` per svuotare il DB
- **Deep linking / azioni vuote**: I bottoni Settings, Profilo e Info in homepage hanno azione vuota
- **View residui/inutilizzati**: `MedicalPatient.swift` (struct inutilizzata dentro `NSManagedObject`), `AnamnesiView.swift` (form parziale), `AddNoteView.swift` (non integrato nel flusso principale), `Item.swift` (modello SwiftData inutilizzato)

---

## Dipendenze

- **Zero dipendenze esterne**. Solo framework Apple:
  - SwiftUI
  - CoreData
  - PDFKit
  - UniformTypeIdentifiers
  - Combine

---

## Build & Requisiti

- **Xcode**: 15.2+
- **Swift**: 5.0
- **iOS**: 17.2+
- **Team**: 8JV2R2Z788 (development signing automatico)
- **Bundle ID**: `it.alessandrodigiusto.MedicaInfo`
- **Non usa Swift Package Manager, CocoaPods, Carthage**
- **Bridge Header**: presente ma vuoto (nessun codice ObjC)
