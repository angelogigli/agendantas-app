# Guida Pubblicazione AgendANTAS

## FASE 1: PREREQUISITI

### 1.1 Installa Flutter SDK
1. Scarica Flutter da: https://docs.flutter.dev/get-started/install/windows
2. Estrai in `C:\flutter`
3. Aggiungi `C:\flutter\bin` alle variabili d'ambiente PATH
4. Riavvia il terminale

### 1.2 Installa Android Studio
1. Scarica da: https://developer.android.com/studio
2. Durante l'installazione, seleziona "Android SDK" e "Android SDK Command-line Tools"
3. Apri Android Studio > Tools > SDK Manager
4. Installa: Android SDK Platform 33 (o superiore)

### 1.3 Verifica installazione
```bash
flutter doctor
```
Assicurati che non ci siano errori per Android.

---

## FASE 2: PREPARA IL PROGETTO

### 2.1 Apri terminale nella cartella del progetto
```bash
cd C:\WEB\antas\cm\Flatlab\admin\template_content\agendantas_app
```

### 2.2 Crea il progetto Flutter (se non esiste android/)
```bash
flutter create --org org.antasonlus --project-name agendantas_app .
```

### 2.3 Installa dipendenze
```bash
flutter pub get
```

---

## FASE 3: CONFIGURA ICONA APP

### 3.1 Aggiungi l'icona
1. Crea un'immagine PNG 1024x1024 pixel (logo ANTAS)
2. Salvala come: `assets/images/app_icon.png`

### 3.2 Aggiungi dipendenza per generare icone
Nel file `pubspec.yaml` aggiungi sotto dev_dependencies:
```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1
```

E in fondo al file:
```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/images/app_icon.png"
  adaptive_icon_background: "#E74C3C"
  adaptive_icon_foreground: "assets/images/app_icon.png"
```

### 3.3 Genera le icone
```bash
flutter pub get
dart run flutter_launcher_icons
```

---

## FASE 4: CREA KEYSTORE (Firma App)

### 4.1 Genera il keystore
Esegui questo comando (sostituisci i dati):
```bash
keytool -genkey -v -keystore C:\keystore\agendantas-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias agendantas
```

Ti chiederà:
- Password keystore (ricordala!)
- Nome e Cognome
- Unità organizzativa: ANTAS
- Organizzazione: ANTAS ONLUS
- Città
- Provincia
- Codice paese: IT

### 4.2 Crea file key.properties
Crea il file `android/key.properties`:
```properties
storePassword=LA_TUA_PASSWORD
keyPassword=LA_TUA_PASSWORD
keyAlias=agendantas
storeFile=C:\\keystore\\agendantas-release-key.jks
```

IMPORTANTE: Non condividere mai questo file! Aggiungilo a .gitignore

---

## FASE 5: BUILD RELEASE

### 5.1 Build App Bundle (per Play Store)
```bash
flutter build appbundle --release
```

Il file sarà in:
`build/app/outputs/bundle/release/app-release.aab`

### 5.2 Oppure Build APK (per test)
```bash
flutter build apk --release
```

Il file sarà in:
`build/app/outputs/flutter-apk/app-release.apk`

---

## FASE 6: PUBBLICA SU GOOGLE PLAY

### 6.1 Crea Account Developer
1. Vai su: https://play.google.com/console
2. Registrati (costa 25$ una tantum)
3. Completa la verifica dell'identità

### 6.2 Crea Nuova App
1. Click "Crea app"
2. Nome: AgendANTAS
3. Lingua: Italiano
4. App o gioco: App
5. Gratuita o a pagamento: Gratuita

### 6.3 Configura Scheda dello Store
Vai in "Scheda dello Store principale" e compila:

**Descrizione breve (max 80 caratteri):**
```
Gestione servizi e laboratori per i clown dottori ANTAS
```

**Descrizione completa:**
```
AgendANTAS è l'app ufficiale per i volontari clown dottori dell'associazione ANTAS ONLUS.

Funzionalità:
• Visualizza i prossimi servizi e laboratori
• Prenota la tua partecipazione alle attività
• Consulta lo storico delle tue attività
• Invia messaggi agli altri clown e ai responsabili
• Visualizza le statistiche personali e globali
• Accedi alla rubrica dei contatti
• Gestisci il tuo profilo

L'app è riservata ai soci ANTAS.
```

### 6.4 Aggiungi Screenshot
Servono almeno 2 screenshot per:
- Telefono (min 320px, max 3840px)
- Tablet 7" (opzionale)
- Tablet 10" (opzionale)

Suggerimento: usa un emulatore per fare gli screenshot

### 6.5 Aggiungi Icona
- Icona app: 512x512 PNG
- Immagine in primo piano: 1024x500 PNG

### 6.6 Classificazione Contenuti
1. Vai in "Contenuti dell'app" > "Classificazione dei contenuti"
2. Compila il questionario
3. L'app dovrebbe ricevere PEGI 3 / Per tutti

### 6.7 Informativa Privacy
Serve un URL con la privacy policy. Puoi creare una pagina semplice su:
https://agenda.antasonlus.org/new/privacy.html

### 6.8 Carica App Bundle
1. Vai in "Release" > "Produzione"
2. Click "Crea nuova release"
3. Carica il file `app-release.aab`
4. Aggiungi note di rilascio:
```
Versione 1.0.0
- Prima release ufficiale
- Login e gestione profilo
- Visualizzazione servizi e laboratori
- Sistema prenotazioni
- Messaggistica interna
- Statistiche personali e globali
```

### 6.9 Invia per Revisione
1. Completa tutte le sezioni richieste
2. Click "Invia per revisione"
3. La revisione richiede 1-7 giorni

---

## FASE 7: iOS (Opzionale)

Per pubblicare su App Store serve:
1. Un Mac con Xcode
2. Account Apple Developer (99€/anno)
3. Procedura simile ma tramite App Store Connect

---

## RISOLUZIONE PROBLEMI

### Errore "Keystore not found"
Verifica che il percorso in key.properties sia corretto (usa \\\\ su Windows)

### Errore "SDK not found"
```bash
flutter doctor --android-licenses
```

### Errore di compilazione
```bash
flutter clean
flutter pub get
flutter build appbundle --release
```

---

## CHECKLIST FINALE

- [ ] Flutter installato e funzionante
- [ ] Android Studio con SDK installato
- [ ] Icona app 1024x1024 creata
- [ ] Keystore generato e conservato in sicurezza
- [ ] key.properties creato
- [ ] App Bundle generato senza errori
- [ ] Account Google Play Console creato
- [ ] Scheda store compilata
- [ ] Screenshot caricati
- [ ] Privacy policy pubblicata
- [ ] App inviata per revisione
