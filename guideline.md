# MedicaInfo — Strategia di Sviluppo e Pubblicazione su App Store

> **A chi serve questo file**: a qualsiasi AI (Gemini, ChatGPT, Claude, DeepSeek, ecc.) che voglia assistere nello sviluppo e nella pubblicazione di MedicaInfo su App Store, comprendendo il posizionamento corretto come **strumento B2B per professionisti della nutrizione**, non come app medica per il pubblico generale.

---

## Indice

1. [Il posizionamento corretto](#1-il-posizionamento-corretto)
2. [Software di Categoria — cosa cambia](#2-software-di-categoria--cosa-cambia)
3. [Implicazioni per i professionisti (Dott. Mario Rossi e colleghi)](#3-implicazioni-per-i-professionisti)
4. [Come restare in regola con Apple](#4-come-restare-in-regola-con-apple)
5. [Linee guida per lo sviluppo futuro](#5-linee-guida-per-lo-sviluppo-futuro)
6. [Checklist pre-pubblicazione](#6-checklist-pre-pubblicazione)
7. [Strategia di pricing](#7-strategia-di-pricing)

---

## 1. Il posizionamento corretto

MedicaInfo **non è un'app medica** destinata al pubblico generale. È uno **strumento di produttività professionale** (B2B) progettato per assistere nutrizionisti, dietisti e medici nella gestione dei pazienti e nella creazione di piani alimentari.

### La distinzione fondamentale

| ❌ Non è | ✅ È |
|---|---|
| Un'app che "fa dimagrire" | Un tool che automatizza la **creazione di piani alimentari professionali** |
| Un sostituto del medico | Una **"penna digitale"** per il professionista |
| Un sistema esperto autonomo | Un **archivio strutturato** di dati del paziente + libreria template |
| Un consiglio medico generico | Un **flusso di lavoro ottimizzato** per chi ha già titolo e responsabilità |

> **Regola d'oro**: L'app non è il nutrizionista. L'app è lo strumento che il nutrizionista usa per lavorare più velocemente. Questa distinzione deve emergere chiaramente in tutta la documentazione, nel codice, in App Store Connect e nei messaggi di marketing.

---

## 2. Software di Categoria — cosa cambia

### Perché Apple approva più facilmente

Quando Apple vede un'app costruita **specificamente per risolvere i problemi di una categoria professionale** (nutrizionisti, dietisti, medici sportivi), le possibilità di approvazione salgono vertiginosamente.

**Il motivo**: Non stai offrendo un consiglio medico autonomo, ma uno **strumento di lavoro** per un professionista che è già abilitato e responsabile del piano nutrizionale. L'app non prende decisioni mediche; è il professionista che le prende, usando l'app come supporto.

### Di conseguenza

- **Non è più "un'app"** nel senso comune — è un **SaaS (Software as a Service)** con un target professionale specifico
- **Le recensioni di App Store** non verranno da pazienti, ma da professionisti che giudicheranno efficienza, UI/UX e risparmio di tempo
- **Il modello di business** può allontanarsi dal classico "acquisto una tantum" verso un abbonamento professionale

---

## 3. Implicazioni per i professionisti

### Il problema che risolvi

Il Dott. Mario Rossi (e come lui migliaia di nutrizionisti) dedica **30 minuti** a creare un piano alimentare a mano. Con MedicaInfo, ne impiega **5**.

**Risultato**: se il professionista vede 10 pazienti al giorno, risparmia **4 ore** di lavoro. Il valore è enorme.

### Cosa vuol dire per lo sviluppo

| Esigenza del professionista | Implicazione tecnica |
|---|---|
| Velocità di compilazione | Form intelligenti con auto-completamento, suggerimenti e dati precalcolati |
| Standardizzazione | **Template Library**: piani alimentari riutilizzabili e condivisibili tra colleghi |
| Riduzione errori | Calcolo automatico dei macro, warning su incompatibilità, validazione dati |
| Delega | Possibilità che un assistente (o lo stesso paziente) inserisca i dati anagrafici, e il professionista solo la parte clinica |
| Privacy | **Dati salvati localmente** (Core Data) — lo sviluppatore non ha accesso. Punto di forza enorme per GDPR |
| Condivisione professionale | Il Dott. Scuderi crea un template e, se vuole, lo condivide con colleghi che usano la stessa piattaforma |

### Pricing

**150€/mese non è caro** — è un investimento che si ripaga da solo in ore di lavoro risparmiate.  
Un professionista che fattura 100€/visita e risparmia 4 ore al giorno (grazie all'automazione) ha un ROI immediato.

---

## 4. Come restare in regola con Apple

### 4.1 Marketing e descrizione App Store

**Mai** scrivere frasi come:
- ❌ "L'app ti fa dimagrire"
- ❌ "Perdi peso con MedicaInfo"
- ❌ "Consigli nutrizionali personalizzati"
- ❌ "L'app sostituisce il tuo nutrizionista"

**Sempre** usare linguaggio come:
- ✅ "Gestione automatizzata di piani alimentari professionali"
- ✅ "Strumento riservato a professionisti della nutrizione"
- ✅ "Ottimizza il flusso di lavoro del dietista/nutrizionista"
- ✅ "Archiviazione strutturata di dati clinici e anamnestici"

### 4.2 Disclaimer obbligatorio nell'app

Inserire un disclaimer legale ben visibile in almeno questi punti:

1. **Al primo avvio** (schermata di benvenuto o onboarding)
2. **Nelle impostazioni** dell'app
3. **Nel footer dei PDF** generati (se presenti)

Testo suggerito per il disclaimer:

> **Disclaimer MedicaInfo**
>
> MedicaInfo è un software destinato all'uso esclusivo da parte di professionisti della salute abilitati (medici, nutrizionisti, dietisti, biologi della nutrizione). I piani alimentari e i contenuti generati attraverso questo software devono essere validati sotto la responsabilità del professionista che li utilizza. MedicaInfo non fornisce consulenza medica, non formula diagnosi e non sostituisce il parere di un professionista sanitario. I dati dei pazienti sono memorizzati esclusivamente sul dispositivo dell'utente. Lo sviluppatore dell'applicazione non ha accesso a tali dati.

### 4.3 Data Sovereignty (GDPR)

Il fatto che i dati siano salvati **localmente su Core Data** (e mai inviati a server esterni) è **il tuo punto di forza più grande** per:

- **Conformità GDPR**: non devi gestire richieste di accesso, rettifica o cancellazione dati
- **Serenità del professionista**: il Dott. Mario Rossi sa che i dati dei suoi pazienti non lasciano mai il suo iPad
- **Sicurezza**: nessun server da violare, nessun data breach possibile

**Se in futuro aggiungessi funzionalità cloud** (es. sincronizzazione tra dispositivi o condivisione template), dovrai:
1. Usare crittografia end-to-end
2. Ottenere il consenso esplicito dell'utente
3. Aggiungere un'opzione "solo locale" per chi non vuole il cloud
4. Aggiornare la privacy policy su App Store Connect

### 4.4 Categorie App Store suggerite

| Campo | Valore |
|---|---|
| **Categoria primaria** | Medical (se vuoi enfasi sanitaria) **oppure** Productivity (più sicuro per l'approvazione) |
| **Sottocategoria** | Healthcare & Fitness **oppure** Business |
| **Classificazione contenuti** | 4+ (nessun contenuto controverso) |
| **Restrizione età** | Nessuna |
| **Made for Kids** | No |
| **Tipo di vendita** | Abbonamento auto-rinnovabile (se SaaS) o pagamento una tantum |

> **Raccomandazione**: scegli **Productivity > Business** come categoria. È la più adatta per un tool professionale B2B. Se in futuro aggiungessi funzionalità direttamente cliniche (es. referti, prescrizioni), allora valuta Medical.

---

## 5. Linee guida per lo sviluppo futuro

### 5.1 Funzionalità da sviluppare (priorità)

Basandoti sul posizionamento B2B professionale, queste funzionalità hanno alto valore:

1. **📋 Template Library**
   - Crea, salva e riutilizza piani alimentari tipo
   - Il Dott. Scuderi crea un template e lo condivide con colleghi
   - Versioning dei template

2. **⚡ Calcolo automatico dei macro**
   - Inserisci gli alimenti → calorie, proteine, carboidrati, grassi calcolati automaticamente
   - Database alimenti integrato (o integrazione con database pubblici come CREA/INRAN)

3. **📄 Generazione PDF professionale**
   - Piano alimentare in PDF con intestazione studio, logo, dati paziente
   - Già in parte presente (PDFKit), da estendere

4. **🔐 Delega assistente**
   - L'assistente inserisce anagrafica e dati preliminari
   - Il nutrizionista approva e finalizza

5. **☁️ (Opzionale) Condivisione sicura tra professionisti**
   - Con crittografia end-to-end
   - Solo con consenso esplicito
   - Per template, non per dati paziente

### 5.2 Cosa NON fare (per restare in regola)

- ❌ **Non aggiungere** un chatbot o AI che dia consigli nutrizionali autonomi
- ❌ **Non fare** claim di dimagrimento o cura nel marketing
- ❌ **Non inviare** dati paziente a server esterni senza crittografia E2E e consenso
- ❌ **Non permettere** la registrazione come "paziente" — solo professionisti
- ❌ **Non integrare** pubblicità (svaluterebbe il posizionamento professionale)

### 5.3 Tecnologia consigliata (stack attuale e futuro)

| Componente | Attuale | Futuro (se necessario) |
|---|---|---|
| UI | SwiftUI | SwiftUI + Widget + App Clips |
| Dati | Core Data locale | Core Data + CloudKit (sync opzionale) |
| PDF | PDFKit | PDFKit + template rendering personalizzato |
| AI/ML | — | Core ML per analisi dati (solo lato dispositivo) |
| Network | — | URLSession con crittografia E2E se cloud |

---

## 6. Checklist pre-pubblicazione

### 6.1 App Store Connect

- [ ] **Categoria**: Productivity (primaria), Business (sottocategoria)
- [ ] **Classificazione**: 4+
- [ ] **Privacy Policy**: redatta e linkata (anche se i dati sono solo locali, Apple richiede una policy)
- [ ] **Marketing URL**: alessandrodigiusto.it (o sito dedicato)
- [ ] **Support URL**: alessandrodigiusto.it/support (o email)
- [ ] **Icona**: professionale, coerente con il posizionamento medical/produttività
- [ ] **Screenshot**: mostra il flusso di lavoro, non solo schermate statiche
- [ ] **Descrizione**: linguaggio B2B, focus su efficienza, nessun claim medico
- [ ] **Parole chiave**: "nutrizionista, dietista, piani alimentari, gestione pazienti, template dieta, software nutrizione, medico, professionista, B2B"
- [ ] **Prezzo / Abbonamento**: decidi modello (consigliato: abbonamento mensile/annuale con free trial)

### 6.2 App

- [ ] **Disclaimer visibile** (impostazioni / onboarding)
- [ ] **Nessun claim medico** in interfaccia o descrizioni
- [ ] **Test su dispositivi reali** (iPhone e iPad)
- [ ] **Test con dati reali** di un nutrizionista (se possibile)
- [ ] **Accessibilità**: Dynamic Type, VoiceOver compatibile
- [ ] **Localizzazione**: almeno ITA (e ENG se vuoi mercato internazionale)

### 6.3 Review Apple

- [ ] **Nessuna funzionalità nascosta** (niente "tap 10 volte sul logo" per attivare modalità segrete)
- [ ] **Nessun riferimento** ad altre app, piattaforme o marchi senza permesso
- [ ] **Login** (se presente): deve avere anche opzione "usa senza account" o "solo locale"
- [ ] **Se abbonamento**: deve rispettare le linee guida Apple sulle auto-renewable subscriptions (SKProductsRequest, StoreKit, UI per gestione abbonamento)

---

## 7. Strategia di pricing

### Modello consigliato: Abbonamento SaaS

| Piano | Prezzo | Target |
|---|---|---|
| **Free Trial** | 14 giorni gratis | Acquisizione utenti |
| **Mensile** | ~14,99€ – 19,99€ | Professionisti che vogliono provare |
| **Annuale** | ~149,99€ (risparmio ~30%) | Professionisti fedeli |
| **Studio** (3+ utenti) | Da definire | Studi associati, SSD |

### Alternative

| Modello | Pro | Contro |
|---|---|---|
| **Pagamento una tantum** | Semplice, nessuna gestione abbonamenti | Il professionista non ha incentivo a restare, nessun revenue ricorrente |
| **Gratis + IAP sblocca funzioni** | Bassa barriera all'ingresso | Le IAP "a sblocco" sono meno professionali per un tool B2B |
| **Abbonamento auto-rinnovabile** | Revenue prevedibile, aggiornamenti continui | Richiede StoreKit, gestione periodi di prova |

> **Consiglio**: inizia con **abbonamento mensile + free trial 14 giorni**. È il modello che i professionisti si aspettano per un SaaS. Usa StoreKit 2 per gestire le sottoscrizioni in modo nativo.

---

## Appendice A: Esempio di testo per App Store

### Titolo
> **MedicaInfo — Gestione Pazienti per Nutrizionisti**

### Sottotitolo
> Crea, organizza e gestisci piani alimentari professionali in modo rapido ed efficiente.

### Descrizione (primi 3 paragrafi)

> MedicaInfo è lo strumento di produttività progettato per professionisti della nutrizione che vogliono ottimizzare il proprio flusso di lavoro.
>
> Dì addio alla scrittura manuale dei piani alimentari. Con MedicaInfo raccogli i dati del paziente, gestisci l'anamnesi sportiva e fisiologica, e mantieni tutto organizzato in un'unica app — veloce, sicura, professionale.
>
> **I dati dei tuoi pazienti rimangono sempre sul tuo dispositivo.** Nessun cloud, nessun accesso esterno, nessuna preoccupazione GDPR.

### Parole chiave (keywords)
> `nutrizionista,dietista,piani alimentari,gestione pazienti,template dieta,software nutrizione,medico,professionista,B2B,pazienti,alimentazione,visita,studio,dietologia,macros,calorie,pdf`

---

## Appendice B: Template disclaimer per SettingsView

Testo pronto per essere inserito nell'app, ad esempio nella schermata Impostazioni o in un onboarding iniziale:

```swift
// Da inserire nel codice, esempio in SettingsView.swift
Section {
    VStack(alignment: .leading, spacing: 12) {
        Image(systemName: "hand.raised.fill")
            .font(.title2)
            .foregroundColor(.blue)
        Text("Disclaimer")
            .font(.headline)
        Text("MedicaInfo è un software destinato all'uso esclusivo da parte di professionisti della salute abilitati (medici, nutrizionisti, dietisti). I dati generati attraverso questo software devono essere validati dal professionista responsabile. MedicaInfo non fornisce consulenza medica, non formula diagnosi e non sostituisce il parere di un professionista sanitario.")
            .font(.caption)
            .foregroundColor(.secondary)
            .fixedSize(horizontal: false, vertical: true)
    }
    .padding(.vertical, 8)
} header: {
    Label("Informazioni Legali", systemImage: "doc.text")
}
```
