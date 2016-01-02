//
//  PaymentViewController.swift
//  Amortized
//
//  Created by Don Miller on 1/1/16.
//  Copyright © 2016 GroundSpeed. All rights reserved.
//

import UIKit
import AVFoundation

class PaymentViewController: UIViewController {

    @IBOutlet weak var txtAmount: UITextField!
    @IBOutlet weak var txtDownPayment: UITextField!
    @IBOutlet weak var txtInterestRate: UITextField!
    @IBOutlet weak var txtTerm: UITextField!
    @IBOutlet weak var lblPayment: UILabel!
    @IBOutlet weak var btnSound: UIButton!
    var soundOn : Bool = false
    
    @IBAction func setSound(sender: AnyObject) {
        if (!soundOn) {
            let image : UIImage = UIImage.init(named: "SoundOn.png")!
            soundOn = true
            btnSound.setImage(image, forState: UIControlState.Normal)
        } else {
            let image : UIImage = UIImage.init(named: "SoundOff.png")!
            soundOn = false
            btnSound.setImage(image, forState: UIControlState.Normal)
        }
    }
    
    @IBAction func clear(sender: AnyObject) {
        txtAmount.text = nil;
        txtDownPayment.text = nil;
        txtInterestRate.text = nil;
        txtTerm.text = nil;
        lblPayment.font = UIFont(name: "Avenir Next", size: 28)
        lblPayment.textColor = UIColor.whiteColor()
        lblPayment.text = "0.00"
    }
    
    @IBAction func calculate(sender: AnyObject) {
        // Make sure none of the values are nil
        txtAmount.text = (txtAmount.text == "") ? "0" : txtAmount.text
        txtDownPayment.text = (txtDownPayment.text == "") ? "0" : txtDownPayment.text
        txtTerm.text = (txtTerm.text == "") ? "0" : txtTerm.text
        txtInterestRate.text = (txtInterestRate.text == "") ? "0" : txtInterestRate.text
        
        getMonthlyPayment()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func getMonthlyPayment() {
        // A = payment Amount per period
        // P = initial Principal (loan amount)
        // r = interest rate per period
        // n = total number of payments or periods
        
        let principal : Float = Float(txtAmount.text!)! - Float(txtDownPayment.text!)!
        let payments = Float(txtTerm.text!)!*12
        let rate = Float(txtInterestRate.text!)!/12/100
        let amount = calculatPMTWithRatePerPeriod(rate, numberOfPayments: payments, loanAmount: principal, futureValue: 0, type: 0)
        
        if (isnan(amount) || isinf(amount))
        {
            lblPayment.font = UIFont.boldSystemFontOfSize(18)
            lblPayment.textColor = UIColor.redColor()
            lblPayment.text = "You must enter all required fields.";
        }
        else
        {
            lblPayment.font = UIFont(name: "Avenir Next", size: 28)
            lblPayment.textColor = UIColor.whiteColor()
            lblPayment.text = String(format: "%.02f", amount)
        }
        
        speak(lblPayment.text!)
        
    }
    
    func calculatPMTWithRatePerPeriod (ratePerPeriod: Float, numberOfPayments: Float, loanAmount: Float, futureValue: Float, type: Float) -> Float {
        
        var q : Float
        
        q = pow(1 + ratePerPeriod, numberOfPayments)
        
        let returnValue = (ratePerPeriod * (futureValue + (q * loanAmount))) / ((-1 + q) * (1 + ratePerPeriod * (type)))
        
        return returnValue

    }
    
    func speak(words: String) {
        if (soundOn) {
            let speechSynthesizer = AVSpeechSynthesizer()
            let synthesizer = AVSpeechUtterance(string: words)
            speechSynthesizer.speakUtterance(synthesizer)
        }
    }
    
}
