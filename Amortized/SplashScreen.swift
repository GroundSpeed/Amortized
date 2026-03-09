import SwiftUI

struct SplashScreen: View {
    var body: some View {
        GeometryReader { geometry in
            VStack {
                // Title at the top
                Text("Amortized")
                    .font(.largeTitle.bold())
                    .padding(.top, geometry.safeAreaInsets.top + 20)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                Spacer()
                
                // Centered AmortizeLogo image
                Image("PayCalc1024")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: geometry.size.width / 2)
                
                Spacer()
                
                // Bottom overlay VStack
                VStack(spacing: 8) {
                    Text("Powered by")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    
                    Image("GroundSpeed Logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width / 2)
                }
                .padding(.bottom, geometry.safeAreaInsets.bottom + 20)
                .frame(maxWidth: .infinity)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(Color("Background").ignoresSafeArea()) // Assuming a color set for adaptive bg
        }
        .preferredColorScheme(.none) // adaptive for light/dark mode
    }
}

struct SplashScreen_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreen()
            .previewDevice("iPhone 14")
            .environment(\.colorScheme, .light)
        
        SplashScreen()
            .previewDevice("iPhone 14")
            .environment(\.colorScheme, .dark)
    }
}
