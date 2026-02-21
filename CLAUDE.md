# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Amortized** (also marketed as "EZ-Payment-Calc") is an iOS app for calculating amortized loan payments and displaying current mortgage rates pulled from Zillow. Bundle ID: `com.groundspeedhq.Pay-Calc`. Swift 5.0, deployment target iOS 13.6 (main app) / 17.6 (tests).

## Build & Test Commands

Build and test via `xcodebuild` from the repo root:

```bash
# Build
xcodebuild -project Amortized.xcodeproj -scheme Amortized -configuration Debug build

# Run tests
xcodebuild -project Amortized.xcodeproj -scheme Amortized -destination 'platform=iOS Simulator,name=iPhone 16' test

# Run a single test class
xcodebuild -project Amortized.xcodeproj -scheme Amortized -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:AmortizedTests/ClassName test
```

Prefer building and running through Xcode for the simulator UI.

## Architecture

The app uses **MVVM** with SwiftUI views and `ObservableObject` view models.

### Entry Point Situation (Migration in Progress)

The `Migration-iOS26` branch is mid-migration. There are two entry points:

- **`AmortizedApp.swift` (repo root)** — New SwiftUI `@main App` struct (iOS 14+ lifecycle). This is the intended future entry point.
- **`Amortized/AppDelegate.swift` + `Amortized/SceneDelegate.swift`** — Old UIKit lifecycle (`@UIApplicationMain`). `SceneDelegate` hosts `Amortized/AmortizedApp.swift` (a plain SwiftUI `View`, not the `@main` struct) via `UIHostingController`.

Only one entry point should be active at a time. The `@main` annotation on the root `AmortizedApp.swift` and `@UIApplicationMain` on `Amortized/AppDelegate.swift` will conflict — this needs to be resolved as part of the migration.

### Key Files

| File | Role |
|------|------|
| `Amortized/PaymentView.swift` | Payment tab UI + `PaymentViewModel` + `InputField` component |
| `Amortized/RatesView.swift` | Rates tab UI + `RatesViewModel` |
| `Amortized/GlobalHelper.swift` | `PaymentService` — amortization PMT calculation |
| `Amortized/ApiService.swift` | `ApiService` — async Zillow API call for mortgage rates |
| `Amortized/Rates.swift` | `Rates` model + `RatesResponse` / `RatesData` / `RatesValues` Codable types |

### Data Flow

- **Payment tab**: User inputs (amount, down payment, rate, term) → `PaymentViewModel.calculate()` → `PaymentService.shared.calculateMonthlyPayment()` → PMT formula → displayed result. Optional `AVSpeechSynthesizer` reads the result aloud.
- **Rates tab**: On appear → `RatesViewModel.loadRates()` → `ApiService.shared.getRatesFromZillow()` → Zillow JSON API → decoded into `RatesResponse` → displayed as today/last-week sections.

### Singletons

- `PaymentService.shared` — stateless calculation service
- `ApiService.shared` — `@MainActor` network service; contains a hardcoded Zillow API key (`API_KEY`)
