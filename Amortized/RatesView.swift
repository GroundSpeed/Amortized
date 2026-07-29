import SwiftUI

struct RatesView: View {
    @StateObject private var viewModel = RatesViewModel()

    var body: some View {
        NavigationStack {
            List {
                if viewModel.isLoading && !viewModel.hasRates {
                    rateStatusView(
                        title: "Loading mortgage rates",
                        message: "Fetching the latest rates from the St. Louis Fed.",
                        systemImage: "arrow.triangle.2.circlepath",
                        showsProgress: true
                    )
                } else if let errorMessage = viewModel.errorMessage, !viewModel.hasRates {
                    rateStatusView(
                        title: "Rates unavailable",
                        message: errorMessage,
                        systemImage: "wifi.exclamationmark",
                        retryAction: {
                            Task { await viewModel.loadRates() }
                        }
                    )
                } else if !viewModel.hasRates {
                    rateStatusView(
                        title: "No rates available",
                        message: "Mortgage rate data is not available right now.",
                        systemImage: "chart.line.downtrend.xyaxis"
                    )
                } else {
                    if let errorMessage = viewModel.errorMessage {
                        Section {
                            Label(errorMessage, systemImage: "exclamationmark.triangle")
                                .font(.subheadline)
                                .foregroundStyle(MortgageClarityTheme.secondaryText)
                                .accessibilityLabel("Rate update failed. \(errorMessage)")
                        }
                    }

                    rateSection(title: "Today", rates: viewModel.todayRates)
                    rateSection(
                        title: "Last Week",
                        rates: viewModel.lastWeekRates,
                        footer: "Rates provided by St. Louis Fed (FRED)"
                    )
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(MortgageClarityTheme.screenBackground)
            .navigationTitle("Mortgage Rates")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(MortgageClarityTheme.brandGreen, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .refreshable {
                await viewModel.loadRates()
            }
            .task {
                await viewModel.loadRates()
            }
        }
    }

    @ViewBuilder
    private func rateSection(
        title: String,
        rates: Rates?,
        footer: String? = nil
    ) -> some View {
        Section {
            RateRow(title: "30 Year Fixed", rate: rates?.thirtyYearFixed ?? "—")
            RateRow(title: "15 Year Fixed", rate: rates?.fifteenYearFixed ?? "—")
            RateRow(title: "5/1 ARM", rate: rates?.fiveOneARM ?? "—")
        } header: {
            Text(title)
                .foregroundStyle(MortgageClarityTheme.brandAccent)
        } footer: {
            if let footer {
                Text(footer)
            }
        }
    }

    private func rateStatusView(
        title: String,
        message: String,
        systemImage: String,
        showsProgress: Bool = false,
        retryAction: (() -> Void)? = nil
    ) -> some View {
        Section {
            VStack(spacing: MortgageClarityTheme.Spacing.standard) {
                if showsProgress {
                    ProgressView()
                        .tint(MortgageClarityTheme.brandAccent)
                        .controlSize(.large)
                        .accessibilityHidden(true)
                } else {
                    Image(systemName: systemImage)
                        .font(.title)
                        .foregroundStyle(MortgageClarityTheme.brandAccent)
                        .accessibilityHidden(true)
                }

                VStack(spacing: MortgageClarityTheme.Spacing.compact) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(MortgageClarityTheme.primaryText)

                    Text(message)
                        .font(.subheadline)
                        .foregroundStyle(MortgageClarityTheme.secondaryText)
                        .multilineTextAlignment(.center)
                }

                if let retryAction {
                    Button("Try Again", action: retryAction)
                        .buttonStyle(.borderedProminent)
                        .tint(MortgageClarityTheme.brandGreen)
                        .frame(minHeight: 44)
                        .accessibilityHint("Attempts to load mortgage rates again")
                }
            }
            .padding(.vertical, MortgageClarityTheme.Spacing.section)
            .frame(maxWidth: .infinity)
            .accessibilityElement(children: .contain)
        }
        .listRowBackground(MortgageClarityTheme.cardBackground)
    }
}

struct RateRow: View {
    let title: String
    let rate: String
    
    var body: some View {
        HStack(spacing: 12) {
            Text(title)
                .font(.custom("AvenirNext-Medium", size: 17, relativeTo: .body))
                .foregroundStyle(MortgageClarityTheme.primaryText)
            Spacer()
            Text(rate)
                .font(.custom("AvenirNext-Regular", size: 17, relativeTo: .body))
                .foregroundStyle(MortgageClarityTheme.brandAccent)
                .fontWeight(.semibold)
        }
        .frame(minHeight: 44)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityValue(rate)
    }
}

@MainActor
class RatesViewModel: ObservableObject {
    @Published private(set) var todayRates: Rates?
    @Published private(set) var lastWeekRates: Rates?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    var hasRates: Bool {
        todayRates != nil || lastWeekRates != nil
    }

    func loadRates() async {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let rates = try await ApiService.shared.getRates()
            todayRates = rates.today
            lastWeekRates = rates.lastWeek
        } catch {
            print("Error loading rates: \(error)")
            errorMessage = "Check your connection and try again."
        }
    }
}
