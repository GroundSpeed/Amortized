//
//  AmortizationModels.swift
//  Amortized
//
//  Copyright © 2016 GroundSpeed. All rights reserved.
//

import Foundation

/// A single row in the loan amortization schedule.
struct AmortizationScheduleRow {
    let paymentNumber: Int
    let paymentDate: Date
    let beginningBalance: Double
    let scheduledPayment: Double
    let extraPayment: Double
    let totalPayment: Double
    let principal: Double
    let interest: Double
    let endingBalance: Double
    let cumulativeInterest: Double
}

/// Summary totals for the amortization report.
struct AmortizationSummary {
    let scheduledPayment: Double
    let scheduledNumberOfPayments: Int
    let actualNumberOfPayments: Int
    let totalEarlyPayments: Double
    let totalInterest: Double
    let totalPaid: Double
    let payoffDate: Date?

    static let empty = AmortizationSummary(
        scheduledPayment: 0,
        scheduledNumberOfPayments: 0,
        actualNumberOfPayments: 0,
        totalEarlyPayments: 0,
        totalInterest: 0,
        totalPaid: 0,
        payoffDate: nil
    )
}
