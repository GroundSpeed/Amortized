//
//  AmortizedTests.swift
//  AmortizedTests
//
//  Created by Don Miller on 1/1/16.
//  Copyright © 2016 GroundSpeed. All rights reserved.
//

import XCTest
@testable import Amortized

class AmortizedTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testJsonCall() {
        let zillowRates : Dictionary<String, String> = ApiHelper().getRatesFromZillow()

        XCTAssertTrue(zillowRates.count == 6)
    }
    
    func testGetPayment() {
        let amount: Float = 100000.00
        let downPayment: Float = 1000.00
        let interestRate: Float = 5.0
        let term: Float = 30
        let label : UILabel = UILabel()
        
        let result = GlobalHelper().getMonthlyPayment(amount, downPayment: downPayment, term: term, interestRate: interestRate, lblPayment: label)
        
        XCTAssert(result.text == "531.45")
    }
    
    
    func testCalculatePayment() {
        let amount: Float = 100000.00
        let downPayment: Float = 1000.00
        let interestRate: Float = 5.0
        let term: Float = 30
        
        let principal : Float = amount - downPayment
        let payments = term*12
        let rate = interestRate/12/100
        
        var result = GlobalHelper().calculatPMTWithRatePerPeriod(rate, numberOfPayments: payments, loanAmount: principal, futureValue: 0.0, type: 0.0)
        result = round(100*result)/100  //Round to two decimal places
        XCTAssert(result == 531.45)

    }
    
    
    
}
