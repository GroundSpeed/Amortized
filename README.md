# Amortized (EZ-Payment-Calc)

iOS app for calculating amortized loan payments and viewing current U.S. mortgage rates from the [St. Louis Fed (FRED) API](https://fred.stlouisfed.org/).

**Bundle ID:** `com.groundspeedhq.Pay-Calc`  
**Requirements:** Xcode, iOS 18.6+ (Simulator or device)  
**Stack:** Swift 5, SwiftUI, MVVM

## Features

- **Payment** — Loan amount, down payment, interest rate, and term; computes monthly payment with optional speech output. Optional schedule inputs: start date, extra payment per period, and lender name. After calculating, open the **Loan Amortization Schedule** report.
- **Loan Amortization Schedule** — Report screen with loan details, summary totals (scheduled payment, actual payments, total interest, etc.), and a full payment-by-payment schedule. Apple-style cards, monospaced numeric columns, horizontal scroll for the table. Toolbar actions for Export PDF, Export CSV, and Share (stubbed for future implementation).
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
- **UI:** SwiftUI views: `PaymentView` (inputs + Calculate + “View Schedule”), `AmortizationReportView` (report with details card, summary card, and payment schedule table), `RatesView`. Reusable `DetailRow` and `ScheduleTableRow` for the report.
- **Logic:** `PaymentService` for monthly PMT and full amortization schedule (`buildAmortizationSchedule`); `ApiService` for FRED (30yr, 15yr, 5/1 ARM).
- **Models:** `AmortizationModels.swift` — `AmortizationScheduleRow`, `AmortizationSummary`. `Rates` for FRED display.
- **Formatting:** `ReportFormatters` — locale-aware currency, percent, and short-date strings for the report and export.

Payment flow: user enters loan parameters (and optionally start date, extra payment, lender) → **Calculate** → `PaymentViewModel` computes payment and builds schedule via `PaymentService.buildAmortizationSchedule` → **View Schedule** pushes `AmortizationReportView` with the same view model (single source of truth). Report does not recalculate; it displays stored schedule and summary.

Rates use FRED series: `MORTGAGE30US`, `MORTGAGE15US`, `MORTGAGE5US`. A FRED API key is required (configured in `ApiService`).
