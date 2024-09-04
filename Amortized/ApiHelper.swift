//
//  ApiHelper.swift
//  Amortized
//
//  Created by Don Miller on 1/3/16.
//  Copyright © 2016 GroundSpeed. All rights reserved.
//

import UIKit

class ApiHelper {

    func getRatesFromZillow() -> Dictionary<String, String> {
        var results : Dictionary<String, String> = Dictionary()

        let API_KEY = "X1-ZWz1f3t3bvl4i3_1brbp"
        let postEndpoint = "http://www.zillow.com/webservice/GetRateSummary.htm?zws-id=\(API_KEY)&output=json"
        print("URL \(postEndpoint)")
        
        let url = NSURL(string: postEndpoint)!
        let session = URLSession.shared
        
        // Create the request
        let request = NSMutableURLRequest(url: url as URL)
        
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // Make the POST call and handle it in a completion handler
        session.dataTask(with: request as URLRequest) { (data, response, error) in
            do {
                if let data = data,
                   let postString = try JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject] {
                    
                    print("output: \(postString)")
                    
                    if let response = postString["response"] as? [String: AnyObject],
                       let today = response["today"] as? [String: String],
                       let lastWeek = response["lastWeek"] as? [String: String] {
                        
                        let todayRate = Rates(thirtyYearFixed: today["thirtyYearFixed"] ?? "",
                                              fifteenYearFixed: today["fifteenYearFixed"] ?? "",
                                              fiveOneARM: today["fiveOneARM"] ?? "")
                        
                        results["todayThirtyYearFixed"] = todayRate.thirtyYearFixed
                        results["todayFifteenYearFixed"] = todayRate.fifteenYearFixed
                        results["todayFiveOneARM"] = todayRate.fiveOneARM
                        
                        let lastWeekRate = Rates(thirtyYearFixed: lastWeek["thirtyYearFixed"] ?? "",
                                                 fifteenYearFixed: lastWeek["fifteenYearFixed"] ?? "",
                                                 fiveOneARM: lastWeek["fiveOneARM"] ?? "")
                        
                        results["lastWeekThirtyYearFixed"] = lastWeekRate.thirtyYearFixed
                        results["lastWeekFifteenYearFixed"] = lastWeekRate.fifteenYearFixed
                        results["lastWeekFiveOneARM"] = lastWeekRate.fiveOneARM
                    }
                } else {
                    if let error = error {
                        print("Error occurred: \(error.localizedDescription)")
                    } else if let data = data, let jsonStr = String(data: data, encoding: .utf8) {
                        print("Error: Could not parse JSON: \(jsonStr)")
                    }
                }
            }
            catch let parseError
            {
                print(parseError)
                // Log the error thrown by `JSONObjectWithData`
                let jsonStr = NSString(data: data! as Data, encoding: NSUTF8StringEncoding)
                print("CATCH: Error could not parse JSON: '\(String(describing: jsonStr))'")
            }
        }.resume()
        sleep(1)
        
        return results
    }
}
