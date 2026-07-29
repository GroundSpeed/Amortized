import SwiftUI

enum MortgageClarityTheme {
    private static let brandUIColor = UIColor(
        red: 0.058,
        green: 0.439,
        blue: 0.192,
        alpha: 1
    )

    static let brandGreen = Color(uiColor: brandUIColor)
    static let brandAccent = Color(
        uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark ? .systemGreen : brandUIColor
        }
    )
    static let screenBackground = Color(uiColor: .systemGroupedBackground)
    static let cardBackground = Color(uiColor: .secondarySystemGroupedBackground)
    static let primaryText = Color.primary
    static let secondaryText = Color.secondary
    static let divider = Color(uiColor: .separator)
    static let shadow = Color.black.opacity(0.08)

    enum Radius {
        static let card: CGFloat = 12
        static let control: CGFloat = 10
    }

    enum Spacing {
        static let compact: CGFloat = 8
        static let standard: CGFloat = 16
        static let section: CGFloat = 24
        static let spacious: CGFloat = 32
    }
}

private struct MortgageClarityCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(MortgageClarityTheme.cardBackground)
            .clipShape(
                RoundedRectangle(
                    cornerRadius: MortgageClarityTheme.Radius.card,
                    style: .continuous
                )
            )
            .shadow(
                color: MortgageClarityTheme.shadow,
                radius: 6,
                x: 0,
                y: 2
            )
    }
}

extension View {
    func mortgageClarityCard() -> some View {
        modifier(MortgageClarityCardModifier())
    }
}
