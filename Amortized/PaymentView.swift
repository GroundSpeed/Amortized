import SwiftUI
import AVFoundation

struct PaymentView: View {
    @StateObject private var viewModel = PaymentViewModel()
    
    var body: some View {
        VStack(spacing: 40) {
            // Payment Display
            Text(viewModel.paymentAmount)
                .font(.custom("AvenirNext-Medium", size: 28))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 99)
                .background(Color(red: 0, green: 0.502, blue: 0.251))
            
            // Input Fields
            VStack(spacing: 15) {
                InputField(title: "Amount", text: $viewModel.amount, placeholder: "$0.00")
                    .keyboardType(.decimalPad)
                
                InputField(title: "Down Payment", text: $viewModel.downPayment, placeholder: "$0.00")
                    .keyboardType(.decimalPad)
                
                InputField(title: "Interest Rate", text: $viewModel.interestRate, placeholder: "%")
                    .keyboardType(.decimalPad)
                
                InputField(title: "Term", text: $viewModel.term, placeholder: "Years")
                    .keyboardType(.numberPad)
            }
            .padding(.horizontal)
            
            // Sound Toggle
            Button(action: { viewModel.toggleSound() }) {
                Image(viewModel.soundOn ? "SoundOn" : "SoundOff")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 36)
            }
            .padding(.top)
            
            // Action Buttons
            VStack(spacing: 12) {
                Button("Clear") {
                    viewModel.clear()
                }
                .font(.custom("AvenirNext-Medium", size: 22))
                .foregroundColor(Color(red: 0.058, green: 0.439, blue: 0.192))
                
                Button("Calculate") {
                    viewModel.calculate()
                }
                .font(.custom("AvenirNext-Medium", size: 22))
                .foregroundColor(Color(red: 0.058, green: 0.439, blue: 0.192))
            }
            
            Spacer()
        }
    }
}

struct InputField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.custom("AvenirNext-Medium", size: 17))
                .frame(width: 153, alignment: .leading)
            
            TextField(placeholder, text: $text)
                .font(.custom("AvenirNext-Regular", size: 14))
                .multilineTextAlignment(.trailing)
                .textFieldStyle(.roundedBorder)
                .frame(width: 154)
        }
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