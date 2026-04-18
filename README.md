# Benji (Native SwiftUI iOS)

This repository has been rewritten from the original web PWA into a native iOS app.

## What is now in this repo

- `Benji.xcodeproj` — native iOS Xcode project
- `Benji/` — Swift + SwiftUI source code
- `legacy-pwa/` — original PWA files kept only for reference
- `Package.swift` + `Sources/BenjiCore` + `Tests/BenjiCoreTests` — pure Swift logic/tests used for CI-friendly unit testing

## Native architecture

- **App lifecycle:** SwiftUI (`@main` in `BenjiApp`)
- **State management:** Observation (`@Observable` `AppState`)
- **Persistence:** SwiftData (`UserAccount`, `AppSettings`, `Category`, `Entry`)
- **Session storage:** Keychain (`SessionService` + `KeychainStore`)
- **Auth:** Local-only signup/login with salted SHA-256 hashes
- **Navigation:** Native `TabView` shell + `NavigationStack`
- **Presentation:** Native `.sheet` (detents), alerts, confirmation dialogs
- **Export:** JSON file to temp URL, shared via `ShareLink`

## Feature mapping (PWA → native)

- **Auth screen** → `Features/Auth/AuthView.swift` (native form + validation)
- **Onboarding flow** → `Features/Onboarding/OnboardingView.swift` (income, hours, real wage, preview)
- **Calculator + keypad + result overlay** → `Features/Calculator/CalculatorView.swift` with native sheet
- **History tab + filters + stats** → `Features/History/HistoryView.swift`
- **Watchlist tab + quick actions** → `Features/Watchlist/WatchlistView.swift`
- **Settings + categories + export + clear history** → `Features/Settings/SettingsView.swift`

## Folder structure

- `BenjiApp.swift`
- `App/` (Root/App state/tab shell)
- `Features/` (Auth, Onboarding, Calculator, History, Watchlist, Settings)
- `Models/` (UserAccount, AppSettings, Category, Entry, enums)
- `Persistence/` (ModelContainer + Keychain)
- `Services/` (Auth, Session, Earnings, History, Export)
- `DesignSystem/` (shared UI components)
- `Utilities/` (formatters + haptics)
- `Resources/` (Assets + Info.plist)

## Build and run (Xcode)

1. Open `Benji.xcodeproj` in Xcode 16+.
2. Select the **Benji** target and an iOS simulator.
3. Build and run.

Deployment target is **iOS 17.0+**.

## Tests

Core logic tests are in `Tests/BenjiCoreTests` and cover:

- earning-per-minute math (hourly/monthly/annual)
- real-wage adjustment math
- history filtering (day/week/month/year)
- stats aggregation
- export JSON schema stability

Run with:

```bash
swift test
```

## Assumptions / TODOs

- v1 is fully local/offline (no backend, no cloud sync).
- App icon uses placeholder asset contents.
- Additional UI polish (custom icon set, more visual refinements) can be layered on top without changing architecture.
