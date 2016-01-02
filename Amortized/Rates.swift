//
//  Rates.swift
//  Amortized
//
//  Created by Don Miller on 1/2/16.
//  Copyright © 2016 GroundSpeed. All rights reserved.
//

import UIKit

class Rates {
    
    var thirtyYearFixed: String
    var fifteenYearFixed: String
    var fiveOneARM: String
    
    init(pThirtyYearFixed: String, pFifteenYearFixed: String, pFiveOneARM: String) {
        self.thirtyYearFixed = "\(pThirtyYearFixed)%"
        self.fifteenYearFixed = "\(pFifteenYearFixed)%"
        self.fiveOneARM = "\(pFiveOneARM)%"
    }

}
