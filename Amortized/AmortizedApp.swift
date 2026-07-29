import SwiftUI

@main
struct AmortizedApp: App {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
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
                                if reduceMotion {
                                    showSplashScreen = false
                                } else {
                                    withAnimation {
                                        showSplashScreen = false
                                    }
                                }
                            }
                        }
                } else {
                    TabView {
                        PaymentView()
                            .tabItem {
                                Image(systemName: "rectangle.grid.3x3.fill")
                                Text("Calculate")
                            }

                        RatesView()
                            .tabItem {
                                Label("Rates", systemImage: "percent")
                            }

                        PlaceholderView(
                            title: "Compare",
                            systemImage: "arrow.left.arrow.right",
                            message: "Compare mortgage scenarios in a future update."
                        )
                        .tabItem {
                            Label("Compare", systemImage: "arrow.left.arrow.right")
                        }

                        PlaceholderView(
                            title: "More",
                            systemImage: "ellipsis",
                            message: "Additional Mortgage Clarity tools are coming soon."
                        )
                        .tabItem {
                            Label("More", systemImage: "ellipsis")
                        }
                    }
                    .tint(MortgageClarityTheme.brandAccent)
                }
            }
        }
    }
}
