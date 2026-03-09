import SwiftUI
import UIKit
import AVFoundation

struct PaymentView: View {
    @StateObject private var viewModel = PaymentViewModel()

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
        } else {
            paymentAmount = String(format: "%.02f", payment)
            if soundOn {
                speak(words: paymentAmount)
            }
        }
    }

    func clear() {
        amount = ""
        downPayment = ""
        interestRate = ""
        term = ""
        paymentAmount = "0.00"
    }

    func toggleSound() {
        soundOn.toggle()
    }

    private func speak(words: String) {
        let utterance = AVSpeechUtterance(string: words)
        speechSynthesizer.speak(utterance)
    }
}
