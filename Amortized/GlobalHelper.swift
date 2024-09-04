//
//  GlobalHelper.swift
//  Amortized
//
//  Created by Don Miller on 1/3/16.
//  Copyright © 2016 GroundSpeed. All rights reserved.
//

import UIKit

class GlobalHelper: NSObject {

    func getMonthlyPayment(amount: Float, downPayment: Float, term: Float, interestRate: Float, lblPayment: UILabel) -> UILabel {
        // A = payment Amount per period
        // P = initial Principal (loan amount)
        // r = interest rate per period
        // n = total number of payments or periods
        
        let principal : Float = amount - downPayment
        let payments = term*12
        let rate = interestRate/12/100
        let amount = calculatPMTWithRatePerPeriod(ratePerPeriod: rate, numberOfPayments: payments, loanAmount: principal, futureValue: 0, type: 0)
        
        if (amount.isNaN || amount.isInfinite)
        {
            lblPayment.font = UIFont.boldSystemFont(ofSize: 18)
            lblPayment.textColor = UIColor.red
            lblPayment.text = "You must enter all required fields.";
        }
        else
        {
            lblPayment.font = UIFont(name: "Avenir Next", size: 28)
            lblPayment.textColor = UIColor.white
            lblPayment.text = String(format: "%.02f", amount)
        }
        
        return lblPayment
    }
    
    func calculatPMTWithRatePerPeriod (ratePerPeriod: Float, numberOfPayments: Float, loanAmount: Float, futureValue: Float, type: Float) -> Float {
        
        var q : Float
        
        q = pow(1 + ratePerPeriod, numberOfPayments)
        
        let returnValue = (ratePerPeriod * (futureValue + (q * loanAmount))) / ((-1 + q) * (1 + ratePerPeriod * (type)))
        
        return returnValue
        
    }

}
