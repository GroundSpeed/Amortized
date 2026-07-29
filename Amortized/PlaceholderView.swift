import SwiftUI

struct PlaceholderView: View {
    let title: String
    let systemImage: String
    let message: String

    var body: some View {
        NavigationStack {
            VStack(spacing: MortgageClarityTheme.Spacing.standard) {
                Image(systemName: systemImage)
                    .font(.system(size: 42, weight: .semibold))
                    .foregroundStyle(MortgageClarityTheme.brandAccent)
                    .frame(width: 72, height: 72)
                    .background(
                        MortgageClarityTheme.brandAccent.opacity(0.12),
                        in: Circle()
                    )
                    .accessibilityHidden(true)

                VStack(spacing: MortgageClarityTheme.Spacing.compact) {
                    Text(title)
                        .font(.title2.bold())
                        .foregroundStyle(MortgageClarityTheme.primaryText)

                    Text("Coming Soon")
                        .font(.headline)
                        .foregroundStyle(MortgageClarityTheme.brandAccent)

                    Text(message)
                        .font(.body)
                        .foregroundStyle(MortgageClarityTheme.secondaryText)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 320)
                }
            }
            .padding(MortgageClarityTheme.Spacing.section)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(MortgageClarityTheme.screenBackground.ignoresSafeArea())
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(title). Coming Soon. \(message)")
        }
    }
}

#Preview("Compare Placeholder") {
    PlaceholderView(
        title: "Compare",
        systemImage: "arrow.left.arrow.right",
        message: "Compare mortgage scenarios in a future update."
    )
}
