//
//  PAYViewController.m
//  EZ Payment Calculator
//
//  Created by Don Miller on 1/31/13.
//  Copyright (c) 2013 GroundSpeed™. All rights reserved.
//

#import "PAYViewController.h"

@interface PAYViewController ()

@end

@implementation PAYViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tVC = (PAYInputsTableViewController *)self.childViewControllers.lastObject;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)btnCalculate:(id)sender
{
    // A = payment Amount per period
    // P = initial Principal (loan amount)
    // r = interest rate per period
    // n = total number of payments or periods
    
    double amount = 0;
    double principal = [self.tVC.txtAmount.text doubleValue] - [self.tVC.txtDownPayment.text doubleValue];
    NSInteger *payments = [self.tVC.txtTerm.text integerValue] * 12;
    double rate = [self.tVC.txtInterestRate.text doubleValue]/12/100;
    
    amount = [self calculatPMTWithRatePerPeriod:rate
                          numberOfPayments:payments
                                loanAmount:principal
                               futureValue:0
                                      type:0];
    _lblMonthlyPayment.text = [NSString stringWithFormat:@"%.02f", amount];
    

}

-(float)calculatPMTWithRatePerPeriod:(double)ratePerPeriod numberOfPayments:(NSInteger)numberOfPayments loanAmount:(double)loanAmount futureValue:(double)futureValue type:(NSInteger)type
{
    
    double q;
    
    q = pow(1 + ratePerPeriod, numberOfPayments);
    
    return (ratePerPeriod * (futureValue + (q * loanAmount))) / ((-1 + q) * (1 + ratePerPeriod * (type)));
    
}

@end
