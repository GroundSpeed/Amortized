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
        let API_KEY = "X1-ZWz1f3t3bvl4i3_1brbp"
        let postEndpoint = "http://www.zillow.com/webservice/GetRateSummary.htm?zws-id=\(API_KEY)&output=json"
        print("URL \(postEndpoint)")
        var results : Dictionary<String, String> = Dictionary()
        
        let url = NSURL(string: postEndpoint)!
        let session = NSURLSession.sharedSession()
        
        // Create the request
        let request = NSMutableURLRequest(URL: url)
        
        request.HTTPMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // Make the POST call and handle it in a completion handler
        session.dataTaskWithRequest(request, completionHandler: { ( data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
            
            do
            {
                if let postString = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? NSDictionary
                {
                    print("output: \(postString)")
                    let response : Dictionary<String, AnyObject> = postString["response"] as! Dictionary<String, AnyObject>
                    let today : Dictionary<String, String> = response["today"] as! Dictionary<String, String>
                    let todayRate = Rates.init(pThirtyYearFixed: today["thirtyYearFixed"]!, pFifteenYearFixed: today["fifteenYearFixed"]!, pFiveOneARM: today["fiveOneARM"]!)
                    results["todayThirtyYearFixed"] = todayRate.thirtyYearFixed
                    results["todayFifteenYearFixed"] = todayRate.fifteenYearFixed
                    results["todayFiveOneARM"] = todayRate.thirtyYearFixed
                    
                    let lastWeek : Dictionary<String, String> = response["lastWeek"] as! Dictionary<String, String>
                    let lastWeekRate = Rates.init(pThirtyYearFixed: lastWeek["thirtyYearFixed"]!, pFifteenYearFixed: lastWeek["fifteenYearFixed"]!, pFiveOneARM: lastWeek["fiveOneARM"]!)
                    results["lastWeekThirtyYearFixed"] = lastWeekRate.thirtyYearFixed
                    results["lastWeekFifteenYearFixed"] = lastWeekRate.fifteenYearFixed
                    results["lastWeekFiveOneARM"] = lastWeekRate.thirtyYearFixed
                }
                else
                {
                    let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                    // No error thrown, but not NSDictionary
                    print("NODICT: Error could not parse JSON: \(jsonStr)")
                }
            }
            catch let parseError
            {
                print(parseError)
                // Log the error thrown by `JSONObjectWithData`
                let jsonStr = NSString(data: data!, encoding: NSUTF8StringEncoding)
                print("CATCH: Error could not parse JSON: '\(jsonStr)'")
            }
        }).resume()
        sleep(1)
        
        return results
    }
}
