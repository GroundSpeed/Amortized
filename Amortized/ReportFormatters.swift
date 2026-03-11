//
//  ReportFormatters.swift
//  Amortized
//
//  Copyright © 2016 GroundSpeed. All rights reserved.
//

import Foundation

/// Formatting helpers for the amortization report (currency, percent, date).
/// Locale-aware; use for display and export (PDF/CSV).
enum ReportFormatters {

    private static let currencyFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = Locale.current.currency?.identifier ?? "USD"
        f.maximumFractionDigits = 2
        f.minimumFractionDigits = 2
        return f
    }()

    private static let percentFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .percent
        f.multiplier = 1
        f.maximumFractionDigits = 2
        f.minimumFractionDigits = 2
        return f
    }()

    private static let shortDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .short
        f.timeStyle = .none
        f.locale = Locale.current
        return f
    }()

    /// Format as currency, e.g. "$1,207.47"
    static func currency(_ value: Double) -> String {
        currencyFormatter.string(from: NSNumber(value: value)) ?? String(format: "%.2f", value)
    }

    /// Format as percent, e.g. "7.89%"
    static func percent(_ value: Double) -> String {
        percentFormatter.string(from: NSNumber(value: value / 100)) ?? String(format: "%.2f%%", value)
    }

    /// Format as short date, e.g. "4/21/2025"
    static func shortDate(_ date: Date) -> String {
        shortDateFormatter.string(from: date)
    }
}
