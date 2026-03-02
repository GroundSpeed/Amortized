import SwiftUI

@main
struct AmortizedApp: App {
    @State private var showSplashScreen = true
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if showSplashScreen {
                    SplashScreen()
                        .transition(.opacity)
                        .zIndex(1)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation {
                                    showSplashScreen = false
                                }
                            }
                        }
                } else {
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
    }
}
