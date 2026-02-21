import SwiftUI

@main
struct AmortizedApp: App {
    var body: some Scene {
        WindowGroup {
            TabView {
                PaymentView()
                    .tabItem {
                        Label("Payment", image: "CalculatePayment")
                    }

                RatesView()
                    .tabItem {
                        Label("Rates", image: "Percent")
                    }
            }
            .tint(Color(red: 0.058, green: 0.439, blue: 0.192))
        }
    }
}
