//
//  GlobalHelper.swift
//  Amortized
//
//  Created by Don Miller on 1/3/16.
//  Copyright © 2016 GroundSpeed. All rights reserved.
//

import Foundation

struct PaymentService {
    static let shared = PaymentService()

    private init() {}

    func calculateMonthlyPayment(amount: Float, downPayment: Float, term: Float, interestRate: Float) -> Float {
        // A = payment Amount per period
        // P = initial Principal (loan amount)
        // r = interest rate per period
        // n = total number of payments or periods

        let principal = amount - downPayment
        let payments = term * 12
        let rate = interestRate / 12 / 100

        return calculatePMT(ratePerPeriod: rate, numberOfPayments: payments, loanAmount: principal)
    }

    private func calculatePMT(ratePerPeriod: Float, numberOfPayments: Float, loanAmount: Float, futureValue: Float = 0, type: Float = 0) -> Float {
        let q = pow(1 + ratePerPeriod, numberOfPayments)
        return (ratePerPeriod * (futureValue + (q * loanAmount))) / ((-1 + q) * (1 + ratePerPeriod * type))
    }

    // MARK: - Amortization Schedule

    /// Builds the full amortization schedule and summary. Returns empty schedule if inputs are invalid.
    func buildAmortizationSchedule(
        loanAmount: Double,
        annualRate: Double,
        loanPeriodYears: Int,
        paymentsPerYear: Int,
        startDate: Date,
        extraPayment: Double
    ) -> (schedule: [AmortizationScheduleRow], summary: AmortizationSummary) {
        guard loanAmount > 0, loanPeriodYears > 0, paymentsPerYear > 0, annualRate >= 0 else {
            return ([], AmortizationSummary(scheduledPayment: 0, scheduledNumberOfPayments: 0, actualNumberOfPayments: 0, totalEarlyPayments: 0, totalInterest: 0))
        }

        let principal = Float(loanAmount)
        let rate = Float(annualRate)
        let term = Float(loanPeriodYears)
        let pmt = calculateMonthlyPayment(amount: principal, downPayment: 0, term: term, interestRate: rate)
        guard pmt.isFinite, !pmt.isNaN, pmt > 0 else {
            return ([], AmortizationSummary(scheduledPayment: 0, scheduledNumberOfPayments: 0, actualNumberOfPayments: 0, totalEarlyPayments: 0, totalInterest: 0))
        }

        let scheduledPayment = Double(pmt)
        let scheduledNumberOfPayments = loanPeriodYears * paymentsPerYear
        let ratePerPeriod = annualRate / 100.0 / Double(paymentsPerYear)
        var calendar = Calendar.current

        var schedule: [AmortizationScheduleRow] = []
        var balance = loanAmount
        var cumulativeInterest: Double = 0
        var paymentNumber = 1

        while balance > 0 && paymentNumber <= scheduledNumberOfPayments * 2 {
            let beginningBalance = balance
            let interest = beginningBalance * ratePerPeriod
            cumulativeInterest += interest

            var principalPortion = scheduledPayment - interest
            if principalPortion > beginningBalance { principalPortion = beginningBalance }
            if principalPortion < 0 { principalPortion = 0 }

            let extra = extraPayment
            let totalPrincipal = principalPortion + extra
            let totalPayment = scheduledPayment + extra
            balance = beginningBalance - totalPrincipal
            if balance < 0 { balance = 0 }

            let paymentDate = calendar.date(byAdding: .month, value: paymentNumber, to: startDate) ?? startDate

            schedule.append(AmortizationScheduleRow(
                paymentNumber: paymentNumber,
                paymentDate: paymentDate,
                beginningBalance: beginningBalance,
                scheduledPayment: scheduledPayment,
                extraPayment: extra,
                totalPayment: totalPayment,
                principal: totalPrincipal,
                interest: interest,
                endingBalance: balance,
                cumulativeInterest: cumulativeInterest
            ))

            paymentNumber += 1
            if balance <= 0 { break }
        }

        let actualNumberOfPayments = schedule.count
        let totalEarlyPayments = extraPayment * Double(actualNumberOfPayments)
        let totalInterest = cumulativeInterest

        let summary = AmortizationSummary(
            scheduledPayment: scheduledPayment,
            scheduledNumberOfPayments: scheduledNumberOfPayments,
            actualNumberOfPayments: actualNumberOfPayments,
            totalEarlyPayments: totalEarlyPayments,
            totalInterest: totalInterest
        )

        return (schedule, summary)
    }
}
