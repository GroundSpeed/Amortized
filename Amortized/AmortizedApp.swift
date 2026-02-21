import SwiftUI

struct AmortizedApp: View {
    var body: some View {
        TabView {
            PaymentView()
                .tabItem {
                    Image("CalculatePayment")
                    Text("Payment")
                }
            
            RatesView()
                .tabItem {
                    Image("Percent")
                    Text("Rates")
                }
        }
        .tint(Color(red: 0.058, green: 0.439, blue: 0.192))
    }
} 