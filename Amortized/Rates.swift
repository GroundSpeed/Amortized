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
    
    init(thirtyYearFixed: String, fifteenYearFixed: String, fiveOneARM: String) {
        self.thirtyYearFixed = String.localizedStringWithFormat("%.2f%%", Float(thirtyYearFixed)!)
        self.fifteenYearFixed = String.localizedStringWithFormat("%.2f%%", Float(fifteenYearFixed)!)
        self.fiveOneARM = String.localizedStringWithFormat("%.2f%%", Float(fiveOneARM)!)
    }

}
