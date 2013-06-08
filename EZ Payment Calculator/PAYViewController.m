//
//  PAYViewController.m
//  EZ Payment Calculator
//
//  Created by Don Miller on 1/31/13.
//  Copyright (c) 2013 GroundSpeed™. All rights reserved.
//

#import "PAYViewController.h"
#include "math.h"

@interface PAYViewController ()

@end

@implementation PAYViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark Actions
- (IBAction)scHomeOther:(id)sender
{
    UISegmentedControl *segmentedControl = (UISegmentedControl *) sender;
    NSInteger selectedSegment = segmentedControl.selectedSegmentIndex;
    
    if (selectedSegment == 0)
    {
        _txtPMI.hidden = false;
        _lblPMI.hidden = false;
    }
    else
    {
        _txtPMI.hidden = true;
        _lblPMI.hidden = true;
    }
}

- (IBAction)btnCalculate:(id)sender
{
    // A = payment Amount per period
    // P = initial Principal (loan amount)
    // r = interest rate per period
    // n = total number of payments or periods
    
    double A = 0;
    double P = [_txtAmount.text doubleValue] - [_txtDownPayment.text doubleValue];
    NSInteger *n = [_txtTerm.text integerValue] * 12;
    double r = [_txtInterestRate.text doubleValue]/12/100;
    
//    double top = pow(r*(1+r),n);
//    double bottom = pow((1+r),n)-1;
    
//    A = P * ( top / bottom);
    
//    A = [calculatPMTWithRateForPeriod:r numberOfPayments:12 loanAmount:P futureValue:0 type:1];
    
    A = [self calculatPMTWithRatePerPeriod:r
                          numberOfPayments:n
                                loanAmount:P
                               futureValue:0
                                      type:0];
    _lblMonthlyPayment.text = [NSString stringWithFormat:@"%.02f", A];
    

}

-(float)calculatPMTWithRatePerPeriod:(double)ratePerPeriod numberOfPayments:(NSInteger)numberOfPayments loanAmount:(double)loanAmount futureValue:(double)futureValue type:(NSInteger)type
{
    
    double q;
    
    q = pow(1 + ratePerPeriod, numberOfPayments);
    
    return (ratePerPeriod * (futureValue + (q * loanAmount))) / ((-1 + q) * (1 + ratePerPeriod * (type)));
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    if (touch != nil)
    {
        [_txtAmount resignFirstResponder];
        [_txtDownPayment resignFirstResponder];
        [_txtInterestRate resignFirstResponder];
        [_txtPMI resignFirstResponder];
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (_txtTerm.tag == 30)
    {
        [_txtTerm resignFirstResponder];
        [_pickTerms setHidden:NO];
    }
    else
    {
        [_pickTerms setHidden:YES];
    }
}

@end
