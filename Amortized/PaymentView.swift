import SwiftUI
import UIKit
import AVFoundation

struct PaymentView: View {
    @StateObject private var viewModel = PaymentViewModel()
    @State private var showAmortizationReport = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture { dismissKeyboard() }

                VStack(spacing: 40) {
                    // Payment Display Header
                    Text(viewModel.paymentAmount)
                        .font(.largeTitle).bold()
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(minHeight: 99)
                        .background(Color(red: 0, green: 0.502, blue: 0.251))
                        .onChange(of: viewModel.paymentAmount) { _, newValue in
                            UIAccessibility.post(notification: .announcement, argument: newValue)
                        }

                    // Input Form
                    Form {
                        Section {
                            HStack {
                                Text("Amount")
                                Spacer()
                                TextField("$0.00", text: $viewModel.amount)
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.trailing)
                                    .foregroundColor(viewModel.amount.isEmpty ? .secondary : .primary)
                                    .font(.body)
                                    .accessibilityLabel("Amount")
                            }
                            HStack {
                                Text("Down Payment")
                                Spacer()
                                TextField("$0.00", text: $viewModel.downPayment)
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.trailing)
                                    .foregroundColor(viewModel.downPayment.isEmpty ? .secondary : .primary)
                                    .font(.body)
                                    .accessibilityLabel("Down Payment")
                            }
                            HStack {
                                Text("Interest Rate")
                                Spacer()
                                TextField("%", text: $viewModel.interestRate)
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.trailing)
                                    .foregroundColor(viewModel.interestRate.isEmpty ? .secondary : .primary)
                                    .font(.body)
                                    .accessibilityLabel("Interest Rate")
                            }
                            HStack {
                                Text("Term")
                                Spacer()
                                TextField("Years", text: $viewModel.term)
                                    .keyboardType(.numberPad)
                                    .multilineTextAlignment(.trailing)
                                    .foregroundColor(viewModel.term.isEmpty ? .secondary : .primary)
                                    .font(.body)
                                    .accessibilityLabel("Term")
                            }
                        }
                        Section(header: Text("Schedule options")) {
                            DatePicker("Start date of loan", selection: $viewModel.startDate, displayedComponents: .date)
                                .accessibilityLabel("Start date of loan")
                            HStack {
                                Text("Extra payment")
                                Spacer()
                                TextField("$0.00", text: $viewModel.extraPayment)
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.trailing)
                                    .foregroundColor(viewModel.extraPayment.isEmpty ? .secondary : .primary)
                                    .font(.body)
                                    .accessibilityLabel("Optional extra payment per period")
                            }
                            HStack {
                                Text("Lender name")
                                Spacer()
                                TextField("Lender", text: $viewModel.lenderName)
                                    .multilineTextAlignment(.trailing)
                                    .foregroundColor(viewModel.lenderName.isEmpty ? .secondary : .primary)
                                    .font(.body)
                                    .accessibilityLabel("Lender name")
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .padding(.horizontal, 16)

                    // Action Buttons
                    VStack(spacing: 12) {
                        Button {
                            dismissKeyboard()
                            viewModel.clear()
                        } label: {
                            Text("Clear")
                                .frame(maxWidth: .infinity)
                                .frame(minHeight: 44)
                                .background(Color.clear)
                                .cornerRadius(12)
                        }
                        .foregroundColor(Color(red: 0.058, green: 0.439, blue: 0.192))
                        .font(.body)
                        .padding(.horizontal, 16)

                        Button {
                            dismissKeyboard()
                            viewModel.calculate()
                        } label: {
                            Text("Calculate")
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(minHeight: 44)
                                .background(Color(red: 0.058, green: 0.439, blue: 0.192))
                                .cornerRadius(12)
                        }
                        .padding(.horizontal, 16)

                        Button {
                            dismissKeyboard()
                            showAmortizationReport = true
                        } label: {
                            Text("View Schedule")
                                .foregroundColor(Color(red: 0.058, green: 0.439, blue: 0.192))
                                .frame(maxWidth: .infinity)
                                .frame(minHeight: 44)
                        }
                        .disabled(!viewModel.canShowReport)
                        .padding(.horizontal, 16)
                    }

                    Spacer()
                } // VStack
            } // ZStack
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.toggleSound()
                    } label: {
                        Image(systemName: viewModel.soundOn ? "speaker.wave.2.fill" : "speaker.slash.fill")
                    }
                    .accessibilityLabel(viewModel.soundOn ? "Sound on" : "Sound off")
                }
            }
            .navigationDestination(isPresented: $showAmortizationReport) {
                AmortizationReportView(viewModel: viewModel)
            }
        } // NavigationStack
    }

    private func dismissKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

@MainActor
class PaymentViewModel: ObservableObject {
    @Published var amount = ""
    @Published var downPayment = ""
    @Published var interestRate = ""
    @Published var term = ""
    @Published var paymentAmount = "0.00"
    @Published var soundOn = false

    // Schedule / report inputs
    @Published var startDate = Date()
    @Published var extraPayment = ""
    @Published var lenderName = ""
    @Published var paymentsPerYear: Int = 12

    // Amortization schedule (populated after calculate)
    @Published var paymentSchedule: [AmortizationScheduleRow] = []
    @Published var amortizationSummary: AmortizationSummary?

    var canShowReport: Bool { !paymentSchedule.isEmpty }

    /// Loan amount (principal) for report display.
    var loanAmount: Double {
        let amt = Double(amount) ?? 0
        let dp = Double(downPayment) ?? 0
        return max(0, amt - dp)
    }

    private let speechSynthesizer = AVSpeechSynthesizer()

    func calculate() {
        let amt = Float(amount) ?? 0
        let dp = Float(downPayment) ?? 0
        let rate = Float(interestRate) ?? 0
        let t = Float(term) ?? 0

        let payment = PaymentService.shared.calculateMonthlyPayment(
            amount: amt,
            downPayment: dp,
            term: t,
            interestRate: rate
        )

        if payment.isNaN || payment.isInfinite {
            paymentAmount = "You must enter all required fields."
            paymentSchedule = []
            amortizationSummary = nil
        } else {
            paymentAmount = String(format: "%.02f", payment)
            if soundOn {
                speak(words: paymentAmount)
            }

            let principal = amt - dp
            guard principal > 0, t > 0 else {
                paymentSchedule = []
                amortizationSummary = nil
                return
            }

            let extra = Double(extraPayment) ?? 0
            let years = Int(t)
            let result = PaymentService.shared.buildAmortizationSchedule(
                loanAmount: Double(principal),
                annualRate: Double(rate),
                loanPeriodYears: years,
                paymentsPerYear: paymentsPerYear,
                startDate: startDate,
                extraPayment: max(0, extra)
            )
            paymentSchedule = result.schedule
            amortizationSummary = result.summary
        }
    }

    func clear() {
        amount = ""
        downPayment = ""
        interestRate = ""
        term = ""
        paymentAmount = "0.00"
        paymentSchedule = []
        amortizationSummary = nil
    }

    func toggleSound() {
        soundOn.toggle()
    }

    private func speak(words: String) {
        let utterance = AVSpeechUtterance(string: words)
        speechSynthesizer.speak(utterance)
    }
}
