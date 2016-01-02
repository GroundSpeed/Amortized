//
//  RatesTableViewController.swift
//  Amortized
//
//  Created by Don Miller on 1/1/16.
//  Copyright © 2016 GroundSpeed. All rights reserved.
//

import UIKit

class RatesTableViewController: UITableViewController {

    @IBOutlet weak var thirtyYearFixedToday: UILabel!
    @IBOutlet weak var fifteenYearFixedToday: UILabel!
    @IBOutlet weak var fiveOneArmToday: UILabel!
    @IBOutlet weak var thirtyYearFixedLastWeek: UILabel!
    @IBOutlet weak var fifteenYearFixedLastWeek: UILabel!
    @IBOutlet weak var fiveOneArmLastWeek: UILabel!
    @IBOutlet var tblRates: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadTextFields()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func loadTextFields() {
        let API_KEY = "X1-ZWz1f3t3bvl4i3_1brbp"
        let postEndpoint = "http://www.zillow.com/webservice/GetRateSummary.htm?zws-id=\(API_KEY)&output=json"
        print("URL \(postEndpoint)")
        
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
                    dispatch_sync(dispatch_get_main_queue()) {
                        print("output: \(postString)")
                        let response : Dictionary<String, AnyObject> = postString["response"] as! Dictionary<String, AnyObject>
                        let today : Dictionary<String, String> = response["today"] as! Dictionary<String, String>
                        let todayRate = Rates.init(pThirtyYearFixed: today["thirtyYearFixed"]!, pFifteenYearFixed: today["fifteenYearFixed"]!, pFiveOneARM: today["fiveOneARM"]!)
                        self.thirtyYearFixedToday.text = todayRate.thirtyYearFixed
                        self.fifteenYearFixedToday.text = todayRate.fifteenYearFixed
                        self.fiveOneArmToday.text = todayRate.fiveOneARM

                        let lastWeek : Dictionary<String, String> = response["lastWeek"] as! Dictionary<String, String>
                        let lastWeekRate = Rates.init(pThirtyYearFixed: lastWeek["thirtyYearFixed"]!, pFifteenYearFixed: lastWeek["fifteenYearFixed"]!, pFiveOneARM: lastWeek["fiveOneARM"]!)
                        self.thirtyYearFixedLastWeek.text = lastWeekRate.thirtyYearFixed
                        self.fifteenYearFixedLastWeek.text = lastWeekRate.fifteenYearFixed
                        self.fiveOneArmLastWeek.text = lastWeekRate.fiveOneARM
                    }
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
    
    }
    
    func connected() -> Bool {
        let scriptUrl = NSURL.init(string: "http://www.google.com")
        let data = NSData.init(contentsOfURL: scriptUrl!)
        
        if ((data) != nil) {
            return true
        } else {
            return false
        }
    }

}
