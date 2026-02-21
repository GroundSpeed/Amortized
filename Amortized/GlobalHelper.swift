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
        
        return calculatePMT(ratePerPeriod: rate, numberOfPayments: payments, loanAmount: principal, futureValue: 0, type: 0)
    }
    
    private func calculatePMT(ratePerPeriod: Float, numberOfPayments: Float, loanAmount: Float, futureValue: Float, type: Float) -> Float {
        let q = pow(1 + ratePerPeriod, numberOfPayments)
        return (ratePerPeriod * (futureValue + (q * loanAmount))) / ((-1 + q) * (1 + ratePerPeriod * type))
    }
}
