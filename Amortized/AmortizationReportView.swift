//
//  AmortizationReportView.swift
//  Amortized
//
//  Copyright © 2016 GroundSpeed. All rights reserved.
//

import SwiftUI

struct AmortizationReportView: View {
    @ObservedObject var viewModel: PaymentViewModel
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var exportMessage: String?
    @State private var showExportAlert = false

    private var summary: AmortizationSummary? { viewModel.amortizationSummary }
    private var schedule: [AmortizationScheduleRow] { viewModel.paymentSchedule }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                loanDetailsCard
                loanSummaryCard
                paymentScheduleSection
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 32)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Amortization Schedule")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        exportPDF()
                    } label: {
                        Label("Export PDF", systemImage: "doc.richtext")
                    }
                    Button {
                        exportCSV()
                    } label: {
                        Label("Export CSV", systemImage: "table")
                    }
                    Button {
                        shareReport()
                    } label: {
                        Label("Share Report", systemImage: "square.and.arrow.up")
                    }
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
                .accessibilityLabel("Export and share options")
            }
        }
        .alert("Export", isPresented: $showExportAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            if let msg = exportMessage { Text(msg) }
        }
    }

    // MARK: - Loan Details Card

    private var loanDetailsCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            DetailRow(label: "Loan amount", value: ReportFormatters.currency(viewModel.loanAmount))
                .accessibilityLabel("Loan amount")
                .accessibilityValue(ReportFormatters.currency(viewModel.loanAmount))
            divider
            DetailRow(label: "Annual interest rate", value: rateFormatted)
                .accessibilityLabel("Annual interest rate")
                .accessibilityValue(rateFormatted)
            divider
            DetailRow(label: "Loan period (years)", value: viewModel.term.isEmpty ? "—" : viewModel.term)
                .accessibilityLabel("Loan period in years")
            divider
            DetailRow(label: "Payments per year", value: "\(viewModel.paymentsPerYear)")
                .accessibilityLabel("Number of payments per year")
            divider
            DetailRow(label: "Start date of loan", value: ReportFormatters.shortDate(viewModel.startDate))
                .accessibilityLabel("Start date of loan")
            divider
            DetailRow(label: "Optional extra payments", value: extraPaymentFormatted)
                .accessibilityLabel("Optional extra payment per period")
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var rateFormatted: String {
        guard let rate = Double(viewModel.interestRate), !viewModel.interestRate.isEmpty else { return "—" }
        return ReportFormatters.percent(rate)
    }

    private var extraPaymentFormatted: String {
        guard let extra = Double(viewModel.extraPayment), !viewModel.extraPayment.isEmpty else { return "—" }
        return ReportFormatters.currency(extra)
    }

    private var divider: some View {
        Divider()
            .padding(.vertical, 8)
    }

    // MARK: - Loan Summary Card

    private var loanSummaryCard: some View {
        Group {
            if horizontalSizeClass == .regular {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    summaryContent
                }
            } else {
                VStack(alignment: .leading, spacing: 0) {
                    summaryContent
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    @ViewBuilder
    private var summaryContent: some View {
        if let s = summary {
            VStack(alignment: .leading, spacing: 4) {
                Text("Scheduled payment")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(ReportFormatters.currency(s.scheduledPayment))
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Scheduled payment")
            .accessibilityValue(ReportFormatters.currency(s.scheduledPayment))

            DetailRow(label: "Scheduled number of payments", value: "\(s.scheduledNumberOfPayments)")
                .accessibilityLabel("Scheduled number of payments")
            DetailRow(label: "Actual number of payments", value: "\(s.actualNumberOfPayments)")
                .accessibilityLabel("Actual number of payments")
            DetailRow(label: "Total early payments", value: ReportFormatters.currency(s.totalEarlyPayments))
                .accessibilityLabel("Total early payments")
            DetailRow(label: "Total interest", value: ReportFormatters.currency(s.totalInterest))
                .accessibilityLabel("Total interest")
        }
    }

    // MARK: - Payment Schedule

    private var paymentScheduleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Payment Schedule")
                .font(.headline)
                .foregroundColor(.primary)

            ScrollView(.horizontal, showsIndicators: true) {
                VStack(spacing: 0) {
                    scheduleTableHeader
                    LazyVStack(spacing: 0) {
                        ForEach(Array(schedule.enumerated()), id: \.offset) { index, row in
                            ScheduleTableRow(row: row, isAlternate: index % 2 == 1)
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }

    private var scheduleTableHeader: some View {
        HStack(alignment: .center, spacing: 12) {
            scheduleHeaderCell("Pmt #", width: 44)
            scheduleHeaderCell("Date", width: 72)
            scheduleHeaderCell("Beg. Bal.", width: 82)
            scheduleHeaderCell("Sched.", width: 72)
            scheduleHeaderCell("Extra", width: 64)
            scheduleHeaderCell("Total", width: 72)
            scheduleHeaderCell("Principal", width: 72)
            scheduleHeaderCell("Interest", width: 68)
            scheduleHeaderCell("End. Bal.", width: 82)
            scheduleHeaderCell("Cum. Int.", width: 82)
        }
        .font(.caption)
        .fontWeight(.semibold)
        .foregroundColor(.secondary)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(minWidth: 750)
        .background(Color(.tertiarySystemGroupedBackground))
        .accessibilityHidden(true)
    }

    private func scheduleHeaderCell(_ title: String, width: CGFloat) -> some View {
        Text(title)
            .frame(width: width, alignment: .leading)
    }

    // MARK: - Export (stubbed)

    private func exportPDF() {
        exportMessage = "PDF export will mirror this report layout. Coming soon."
        showExportAlert = true
    }

    private func exportCSV() {
        let csv = buildCSV()
        // Stub: in a full implementation, write to temp file and present share sheet
        exportMessage = "CSV export prepared (\(schedule.count) rows). Share integration coming soon."
        showExportAlert = true
    }

    private func shareReport() {
        exportMessage = "Share will offer PDF or CSV. Coming soon."
        showExportAlert = true
    }

    private func buildCSV() -> String {
        var lines: [String] = []
        lines.append("Payment #,Payment Date,Beginning Balance,Scheduled Payment,Extra Payment,Total Payment,Principal,Interest,Ending Balance,Cumulative Interest")
        for row in schedule {
            let dateStr = ReportFormatters.shortDate(row.paymentDate)
            lines.append("\(row.paymentNumber),\(dateStr),\(row.beginningBalance),\(row.scheduledPayment),\(row.extraPayment),\(row.totalPayment),\(row.principal),\(row.interest),\(row.endingBalance),\(row.cumulativeInterest)")
        }
        return lines.joined(separator: "\n")
    }
}

// MARK: - Detail Row

struct DetailRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.body)
                .foregroundColor(.primary)
            Spacer()
            Text(value)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.trailing)
        }
    }
}

// MARK: - Schedule Table Row

struct ScheduleTableRow: View {
    let row: AmortizationScheduleRow
    let isAlternate: Bool

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Text("\(row.paymentNumber)")
                .frame(width: 44, alignment: .leading)
                .font(.system(.caption, design: .monospaced))
            Text(ReportFormatters.shortDate(row.paymentDate))
                .frame(width: 72, alignment: .leading)
                .font(.system(.caption, design: .monospaced))
            Text(ReportFormatters.currency(row.beginningBalance))
                .frame(width: 82, alignment: .trailing)
                .font(.system(.caption, design: .monospaced))
            Text(ReportFormatters.currency(row.scheduledPayment))
                .frame(width: 72, alignment: .trailing)
                .font(.system(.caption, design: .monospaced))
            Text(ReportFormatters.currency(row.extraPayment))
                .frame(width: 64, alignment: .trailing)
                .font(.system(.caption, design: .monospaced))
            Text(ReportFormatters.currency(row.totalPayment))
                .frame(width: 72, alignment: .trailing)
                .font(.system(.caption, design: .monospaced))
            Text(ReportFormatters.currency(row.principal))
                .frame(width: 72, alignment: .trailing)
                .font(.system(.caption, design: .monospaced))
            Text(ReportFormatters.currency(row.interest))
                .frame(width: 68, alignment: .trailing)
                .font(.system(.caption, design: .monospaced))
            Text(ReportFormatters.currency(row.endingBalance))
                .frame(width: 82, alignment: .trailing)
                .font(.system(.caption, design: .monospaced))
            Text(ReportFormatters.currency(row.cumulativeInterest))
                .frame(width: 82, alignment: .trailing)
                .font(.system(.caption, design: .monospaced))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(minWidth: 750, minHeight: 44, alignment: .leading)
        .background(isAlternate ? Color(.tertiarySystemGroupedBackground).opacity(0.5) : Color.clear)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Payment \(row.paymentNumber), \(ReportFormatters.shortDate(row.paymentDate)), Principal \(ReportFormatters.currency(row.principal)), Interest \(ReportFormatters.currency(row.interest))")
    }
}

// MARK: - Preview

#Preview("Amortization Report") {
    let vm = PaymentViewModel()
    vm.amount = "100000"
    vm.downPayment = "0"
    vm.interestRate = "7.89"
    vm.term = "10"
    vm.extraPayment = "900"
    vm.lenderName = "Green Tree"
    vm.calculate()
    return NavigationStack {
        AmortizationReportView(viewModel: vm)
    }
}
