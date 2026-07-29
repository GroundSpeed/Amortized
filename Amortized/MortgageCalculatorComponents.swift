import SwiftUI
import UIKit

enum PaymentSection: String, CaseIterable, Identifiable {
    case calculator = "Calculator"
    case schedule = "Schedule"

    var id: Self { self }

    var systemImage: String {
        switch self {
        case .calculator: "calculator"
        case .schedule: "calendar"
        }
    }
}

struct MortgageClarityHeader: View {
    let soundOn: Bool
    let onSoundToggle: () -> Void
    let onSettings: () -> Void

    var body: some View {
        ZStack {
            Text("Mortgage Clarity")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(.white)

            HStack {
                Button(action: onSoundToggle) {
                    Image(systemName: soundOn ? "speaker.wave.2.fill" : "speaker.slash.fill")
                        .frame(width: 44, height: 44)
                }
                .accessibilityLabel(soundOn ? "Sound on" : "Sound off")
                .accessibilityHint("Toggles spoken payment results")

                Spacer()

                Button(action: onSettings) {
                    Image(systemName: "gearshape")
                        .frame(width: 44, height: 44)
                }
                .accessibilityLabel("Settings")
                .accessibilityHint("Settings are coming soon")
            }
            .font(.title3.weight(.semibold))
            .foregroundStyle(.white)
        }
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity)
        .frame(height: 58)
        .background(MortgageClarityTheme.brandGreen)
    }
}

struct MortgageSegmentedControl: View {
    @Binding var selection: PaymentSection

    var body: some View {
        Picker("Calculator or schedule", selection: $selection) {
            ForEach(PaymentSection.allCases) { section in
                Label(section.rawValue, systemImage: section.systemImage)
                    .tag(section)
            }
        }
        .pickerStyle(.segmented)
        .accessibilityHint("Switches between loan inputs and the amortization schedule")
    }
}

struct MortgageTextFieldRow: View {
    let label: String
    let placeholder: String
    let suffix: String?
    let keyboardType: UIKeyboardType
    @Binding var text: String

    var body: some View {
        HStack(spacing: 12) {
            Text(label)
                .foregroundStyle(MortgageClarityTheme.primaryText)

            Spacer(minLength: 16)

            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .multilineTextAlignment(.trailing)
                .foregroundStyle(MortgageClarityTheme.brandAccent)
                .fontWeight(text.isEmpty ? .regular : .semibold)
                .frame(minWidth: 100)
                .accessibilityLabel(label)

            if let suffix, !text.isEmpty {
                Text(suffix)
                    .foregroundStyle(MortgageClarityTheme.secondaryText)
                    .accessibilityHidden(true)
            }
        }
        .frame(minHeight: 44)
    }
}

struct MortgageDateRow: View {
    @Binding var date: Date

    var body: some View {
        DatePicker(
            "Start Date",
            selection: $date,
            displayedComponents: .date
        )
        .tint(MortgageClarityTheme.brandAccent)
        .frame(minHeight: 44)
        .accessibilityLabel("Start date of loan")
    }
}

struct PaymentPreviewCard: View {
    let paymentAmount: String

    private var displayAmount: String {
        guard let value = Double(paymentAmount), value > 0 else { return "—" }
        return ReportFormatters.currency(value)
    }

    var body: some View {
        VStack(spacing: 6) {
            Text("Your Monthly Payment")
                .font(.headline)

            Text(displayAmount)
                .font(.system(.largeTitle, design: .rounded, weight: .bold))
                .minimumScaleFactor(0.7)
                .lineLimit(1)

            Text("Estimated principal and interest")
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.85))
        }
        .foregroundStyle(.white)
        .padding(MortgageClarityTheme.Spacing.standard)
        .frame(maxWidth: .infinity)
        .background(MortgageClarityTheme.brandGreen)
        .clipShape(
            RoundedRectangle(
                cornerRadius: MortgageClarityTheme.Radius.card,
                style: .continuous
            )
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Your monthly payment")
        .accessibilityValue(
            displayAmount == "—"
                ? "Not calculated"
                : "\(displayAmount), estimated principal and interest"
        )
        .onChange(of: displayAmount) { oldValue, newValue in
            guard newValue != "—", newValue != oldValue else { return }
            UIAccessibility.post(
                notification: .announcement,
                argument: "Monthly payment \(newValue)"
            )
        }
    }
}

struct LoanSummaryCard: View {
    let summary: AmortizationSummary?

    private var items: [LoanSummaryItem] {
        [
            LoanSummaryItem(
                title: "Payoff Date",
                image: "calendar",
                value: summary?.payoffDate.map(ReportFormatters.monthYear) ?? "—"
            ),
            LoanSummaryItem(
                title: "Total Interest",
                image: "chart.pie.fill",
                value: summary.map { ReportFormatters.currency($0.totalInterest) } ?? "—"
            ),
            LoanSummaryItem(
                title: "Total Paid",
                image: "dollarsign.circle",
                value: summary.map { ReportFormatters.currency($0.totalPaid) } ?? "—"
            )
        ]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Loan Summary")
                .font(.headline)

            HStack(spacing: 0) {
                ForEach(Array(items.enumerated()), id: \.element.title) { index, item in
                    if index > 0 {
                        Divider()
                    }

                    VStack(spacing: 6) {
                        Image(systemName: item.image)
                            .font(.title2)
                            .foregroundStyle(MortgageClarityTheme.brandAccent)
                            .accessibilityHidden(true)
                        Text(item.title)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                        Text(item.value)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(
                                item.value == "—"
                                    ? MortgageClarityTheme.secondaryText
                                    : MortgageClarityTheme.brandAccent
                            )
                            .minimumScaleFactor(0.75)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(item.title)
                    .accessibilityValue(item.value == "—" ? "Not calculated" : item.value)
                }
            }
            .accessibilityElement(children: .contain)
        }
        .padding(MortgageClarityTheme.Spacing.standard)
        .mortgageClarityCard()
    }
}

private struct LoanSummaryItem {
    let title: String
    let image: String
    let value: String
}

struct ScheduleEmptyState: View {
    let returnToCalculator: () -> Void

    var body: some View {
        VStack(spacing: MortgageClarityTheme.Spacing.standard) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 40, weight: .semibold))
                .foregroundStyle(MortgageClarityTheme.brandAccent)
                .accessibilityHidden(true)

            Text("No Schedule Yet")
                .font(.title3.bold())

            Text("Enter your loan details and calculate a payment to create an amortization schedule.")
                .foregroundStyle(MortgageClarityTheme.secondaryText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 320)

            Button("Return to Calculator", action: returnToCalculator)
                .buttonStyle(.borderedProminent)
                .tint(MortgageClarityTheme.brandGreen)
                .controlSize(.large)
        }
        .padding(MortgageClarityTheme.Spacing.section)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .contain)
    }
}
