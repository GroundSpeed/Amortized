# Amortized (EZ-Payment-Calc)

iOS app for calculating amortized loan payments and viewing current U.S. mortgage rates from the [St. Louis Fed (FRED) API](https://fred.stlouisfed.org/).

**Bundle ID:** `com.groundspeedhq.Pay-Calc`  
**Requirements:** Xcode, iOS 18.6+ (Simulator or device)  
**Stack:** Swift 5, SwiftUI, MVVM

## Features

- **Payment** — Loan amount, down payment, interest rate, and term; computes monthly payment with optional speech output.
- **Rates** — Live 30-year fixed, 15-year fixed, and 5/1 ARM rates from FRED (today vs. last week).

## Build & Run

From the repo root:

```bash
# Build
xcodebuild -project Amortized.xcodeproj -scheme Amortized -configuration Debug -sdk iphonesimulator build
```

Or open `Amortized.xcodeproj` in Xcode and run on a simulator (recommended).

## Tests

```bash
# List simulator IDs
xcodebuild -showdestinations

# Run all tests (replace <UUID> with a simulator ID)
xcodebuild -project Amortized.xcodeproj -scheme Amortized -destination 'platform=iOS Simulator,id=<UUID>' test

# Run a single test class
xcodebuild -project Amortized.xcodeproj -scheme Amortized -destination 'platform=iOS Simulator,id=<UUID>' -only-testing:AmortizedTests/ClassName test
```

Tests cover `PaymentService` (PMT calculations), FRED JSON decoding, and view models.

## Architecture

- **Entry:** `AmortizedApp.swift` — SwiftUI `App` with a `TabView` (Payment + Rates).
- **UI:** SwiftUI views (`PaymentView`, `RatesView`) and `ObservableObject` view models.
- **Logic:** `PaymentService` for amortization math; `ApiService` for FRED (30yr, 15yr, 5/1 ARM).

Rates use FRED series: `MORTGAGE30US`, `MORTGAGE15US`, `MORTGAGE5US`. A FRED API key is required (configured in `ApiService`).
