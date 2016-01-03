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
    
}
