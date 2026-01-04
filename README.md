# AgendANTAS - App Mobile

App mobile Flutter per la gestione dei clown dottori ANTAS.

## Requisiti

- Flutter SDK 3.0 o superiore
- Dart SDK 3.0 o superiore
- Android Studio / VS Code con estensioni Flutter
- Per Android: Android SDK
- Per iOS: Xcode (solo su macOS)

## Installazione

1. Installa Flutter seguendo la guida ufficiale: https://flutter.dev/docs/get-started/install

2. Clona o copia questa cartella

3. Installa le dipendenze:
```bash
cd agendantas_app
flutter pub get
```

4. L'URL del server e' gia' configurato in `lib/services/api_service.dart`:
```dart
static const String baseUrl = 'https://agenda.antasonlus.org/new/handlers/';
static const String imageUrl = 'https://agenda.antasonlus.org/new/foto/';
```

## Esecuzione

### Android
```bash
flutter run
```

### iOS (solo su macOS)
```bash
flutter run -d ios
```

### Web (per test)
```bash
flutter run -d chrome
```

## Build

### Android APK
```bash
flutter build apk --release
```
L'APK sara' in `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle (per Play Store)
```bash
flutter build appbundle --release
```

### iOS (solo su macOS)
```bash
flutter build ios --release
```

## Struttura del Progetto

```
lib/
├── main.dart              # Entry point
├── models/                # Modelli dati
│   ├── user.dart
│   ├── activity.dart
│   ├── message.dart
│   ├── contact.dart
│   └── stats.dart
├── services/              # Servizi API
│   ├── api_service.dart
│   └── auth_service.dart
├── screens/               # Schermate
│   ├── login_screen.dart
│   ├── main_screen.dart
│   ├── dashboard_screen.dart
│   ├── services_screen.dart
│   ├── workshops_screen.dart
│   ├── messages_screen.dart
│   ├── contacts_screen.dart
│   ├── statistics_screen.dart
│   ├── profile_screen.dart
│   ├── activity_detail_screen.dart
│   ├── rules_screen.dart
│   └── help_screen.dart
├── widgets/               # Widget riutilizzabili
│   ├── stat_card.dart
│   ├── activity_card.dart
│   └── empty_state.dart
└── utils/                 # Utilita'
    └── theme.dart
```

## Funzionalita'

- Login/Logout con sessione persistente
- Dashboard con statistiche e attivita' in programma
- Gestione servizi e laboratori
- Prenotazione/cancellazione attivita'
- Messaggistica interna
- Rubrica contatti
- Statistiche personali e globali
- Regolamento con accettazione
- Gestione profilo

## Personalizzazione

### Colori
Modifica i colori in `lib/utils/theme.dart`

### Logo
Aggiungi il logo in `assets/images/` e aggiorna `pubspec.yaml`

### Icona App
Usa il package `flutter_launcher_icons` per generare le icone

## Note per iOS

Per compilare per iOS e' necessario:
1. Un Mac con Xcode installato
2. Un account Apple Developer (per distribuzione)
3. Configurare i certificati e provisioning profiles

## Supporto

Per assistenza contatta i responsabili ANTAS.
