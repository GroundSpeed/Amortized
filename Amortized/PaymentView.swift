import AVFoundation
import SwiftUI
import UIKit

struct PaymentView: View {
    @StateObject private var viewModel = PaymentViewModel()
    @State private var selectedSection = PaymentSection.calculator
    @State private var showSettingsPlaceholder = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                MortgageClarityHeader(
                    soundOn: viewModel.soundOn,
                    onSoundToggle: viewModel.toggleSound,
                    onSettings: { showSettingsPlaceholder = true }
                )

                MortgageSegmentedControl(selection: $selectedSection)
                    .padding(.horizontal, MortgageClarityTheme.Spacing.standard)
                    .padding(.vertical, 10)

                Group {
                    switch selectedSection {
                    case .calculator:
                        calculatorContent
                    case .schedule:
                        scheduleContent
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .background(MortgageClarityTheme.screenBackground.ignoresSafeArea())
            .alert("Settings", isPresented: $showSettingsPlaceholder) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Mortgage Clarity settings are coming soon.")
            }
        }
    }

    private var calculatorContent: some View {
        ScrollView {
            VStack(spacing: 12) {
                inputCard

                if let validationMessage = viewModel.validationMessage {
                    Label(validationMessage, systemImage: "exclamationmark.circle.fill")
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .accessibilityLabel("Input error. \(validationMessage)")
                }

                actionButtons

                PaymentPreviewCard(paymentAmount: viewModel.paymentAmount)
                LoanSummaryCard(summary: viewModel.amortizationSummary)
                scheduleButton
            }
            .padding(.horizontal, MortgageClarityTheme.Spacing.standard)
            .padding(.bottom, MortgageClarityTheme.Spacing.section)
        }
        .scrollDismissesKeyboard(.interactively)
        .contentShape(Rectangle())
        .onTapGesture { dismissKeyboard() }
    }

    private var inputCard: some View {
        VStack(spacing: 0) {
            MortgageTextFieldRow(
                label: "Loan Amount",
                placeholder: "$0",
                suffix: nil,
                keyboardType: .decimalPad,
                text: $viewModel.amount
            )
            rowDivider
            MortgageTextFieldRow(
                label: "Down Payment",
                placeholder: "$0",
                suffix: nil,
                keyboardType: .decimalPad,
                text: $viewModel.downPayment
            )
            rowDivider
            MortgageTextFieldRow(
                label: "Interest Rate",
                placeholder: "0.00",
                suffix: "%",
                keyboardType: .decimalPad,
                text: $viewModel.interestRate
            )
            rowDivider
            MortgageTextFieldRow(
                label: "Loan Term",
                placeholder: "Years",
                suffix: "Years",
                keyboardType: .numberPad,
                text: $viewModel.term
            )
            rowDivider
            MortgageDateRow(date: $viewModel.startDate)
            rowDivider
            MortgageTextFieldRow(
                label: "Extra Payment (Monthly)",
                placeholder: "$0",
                suffix: nil,
                keyboardType: .decimalPad,
                text: $viewModel.extraPayment
            )
        }
        .padding(.horizontal, MortgageClarityTheme.Spacing.standard)
        .mortgageClarityCard()
    }

    private var rowDivider: some View {
        Divider()
            .overlay(MortgageClarityTheme.divider)
    }

    private var actionButtons: some View {
        HStack(spacing: 12) {
            Button {
                dismissKeyboard()
                viewModel.clear()
            } label: {
                Text("Clear")
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            .buttonStyle(.bordered)
            .tint(MortgageClarityTheme.brandAccent)

            Button {
                dismissKeyboard()
                viewModel.calculate()
            } label: {
                Text("Calculate")
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            .buttonStyle(.borderedProminent)
            .tint(MortgageClarityTheme.brandGreen)
        }
    }

    private var scheduleButton: some View {
        Button {
            dismissKeyboard()
            selectedSection = .schedule
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "chart.bar.xaxis")
                    .foregroundStyle(MortgageClarityTheme.brandAccent)
                    .accessibilityHidden(true)
                Text("View Amortization Schedule")
                    .foregroundStyle(MortgageClarityTheme.primaryText)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(MortgageClarityTheme.secondaryText)
                    .accessibilityHidden(true)
            }
            .padding(.horizontal, MortgageClarityTheme.Spacing.standard)
            .frame(minHeight: 52)
            .mortgageClarityCard()
        }
        .buttonStyle(.plain)
        .accessibilityHint(
            viewModel.canShowReport
                ? "Shows the calculated payment schedule"
                : "Shows instructions for creating a schedule"
        )
    }

    @ViewBuilder
    private var scheduleContent: some View {
        if viewModel.canShowReport {
            AmortizationReportView(viewModel: viewModel)
        } else {
            ScheduleEmptyState {
                selectedSection = .calculator
            }
        }
    }

    private func dismissKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}

@MainActor
class PaymentViewModel: ObservableObject {
    @Published var amount = "" {
        didSet { invalidateCalculatedResults() }
    }
    @Published var downPayment = "" {
        didSet { invalidateCalculatedResults() }
    }
    @Published var interestRate = "" {
        didSet { invalidateCalculatedResults() }
    }
    @Published var term = "" {
        didSet { invalidateCalculatedResults() }
    }
    @Published var paymentAmount = "0.00"
    @Published var soundOn = false
    @Published var validationMessage: String?

    @Published var startDate = PaymentViewModel.firstDayOfNextMonth {
        didSet { invalidateCalculatedResults() }
    }

    private static var firstDayOfNextMonth: Date {
        let calendar = Calendar.current
        let now = Date()
        guard let nextMonth = calendar.date(byAdding: .month, value: 1, to: now),
              let first = calendar.date(
                from: calendar.dateComponents([.year, .month], from: nextMonth)
              ) else {
            return now
        }
        return first
    }

    @Published var extraPayment = "" {
        didSet { invalidateCalculatedResults() }
    }
    @Published var lenderName = ""
    @Published var paymentsPerYear = 12 {
        didSet { invalidateCalculatedResults() }
    }
    @Published var paymentSchedule: [AmortizationScheduleRow] = []
    @Published var amortizationSummary: AmortizationSummary?

    var canShowReport: Bool { !paymentSchedule.isEmpty }

    var loanAmount: Double {
        let amountValue = Double(amount) ?? 0
        let downPaymentValue = Double(downPayment) ?? 0
        return max(0, amountValue - downPaymentValue)
    }

    private let speechSynthesizer = AVSpeechSynthesizer()

    func calculate() {
        clearCalculatedResults()
        validationMessage = validateInputs()
        guard validationMessage == nil else { return }

        let amountValue = Float(amount) ?? 0
        let downPaymentValue = Float(downPayment) ?? 0
        let rateValue = Float(interestRate) ?? 0
        let termValue = Float(Int(term) ?? 0)

        let payment = PaymentService.shared.calculateMonthlyPayment(
            amount: amountValue,
            downPayment: downPaymentValue,
            term: termValue,
            interestRate: rateValue
        )

        guard payment.isFinite, !payment.isNaN, payment > 0 else {
            validationMessage = "Check the loan details and try again."
            return
        }

        paymentAmount = String(format: "%.02f", payment)
        if soundOn {
            speak(words: paymentAmount)
        }

        let principal = amountValue - downPaymentValue
        let result = PaymentService.shared.buildAmortizationSchedule(
            loanAmount: Double(principal),
            annualRate: Double(rateValue),
            loanPeriodYears: Int(termValue),
            paymentsPerYear: paymentsPerYear,
            startDate: startDate,
            extraPayment: max(0, Double(extraPayment) ?? 0)
        )
        guard !result.schedule.isEmpty else {
            validationMessage = "A payment schedule could not be created from these details."
            clearCalculatedResults()
            return
        }
        paymentSchedule = result.schedule
        amortizationSummary = result.summary
    }

    func clear() {
        amount = ""
        downPayment = ""
        interestRate = ""
        term = ""
        extraPayment = ""
        paymentAmount = "0.00"
        startDate = PaymentViewModel.firstDayOfNextMonth
        paymentSchedule = []
        amortizationSummary = nil
        validationMessage = nil
    }

    func toggleSound() {
        soundOn.toggle()
    }

    private func validateInputs() -> String? {
        guard let amountValue = Double(amount), amountValue > 0,
              let rateValue = Double(interestRate), rateValue > 0,
              let termValue = Int(term), termValue > 0 else {
            return "Enter a loan amount, interest rate, and loan term."
        }

        let downPaymentValue = downPayment.isEmpty ? 0 : Double(downPayment)
        guard let downPaymentValue, downPaymentValue >= 0 else {
            return "Down payment cannot be negative."
        }
        guard downPaymentValue < amountValue else {
            return "Down payment must be less than the loan amount."
        }

        let extraPaymentValue = extraPayment.isEmpty ? 0 : Double(extraPayment)
        guard let extraPaymentValue, extraPaymentValue >= 0 else {
            return "Extra payment cannot be negative."
        }

        return nil
    }

    private func invalidateCalculatedResults() {
        clearCalculatedResults()
        validationMessage = nil
    }

    private func clearCalculatedResults() {
        paymentAmount = "0.00"
        paymentSchedule = []
        amortizationSummary = nil
    }

    private func speak(words: String) {
        let utterance = AVSpeechUtterance(string: words)
        speechSynthesizer.speak(utterance)
    }
}
