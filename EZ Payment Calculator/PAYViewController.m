//
//  PAYViewController.m
//  EZ Payment Calculator
//
//  Created by Don Miller on 1/31/13.
//  Copyright (c) 2013 GroundSpeed™. All rights reserved.
//

#import "PAYViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface PAYViewController ()

@end

@implementation PAYViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tVC = (PAYInputsTableViewController *)self.childViewControllers.lastObject;
    self.tVC.delegate = self;
    _sound = false;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)btnCalculate:(id)sender
{
    [self getMonthlyPayment];
}

- (IBAction)btnClear:(id)sender
{
    self.tVC.txtAmount.text = nil;
    self.tVC.txtDownPayment.text = nil;
    self.tVC.txtInterestRate.text = nil;
    self.tVC.txtTerm.text = nil;
    _lblMonthlyPayment.font = [UIFont fontWithName:@"Avenir Next" size:28];
    _lblMonthlyPayment.textColor = [UIColor whiteColor];
    _lblMonthlyPayment.text = @"0.00";
}

-(void)getMonthlyPayment
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
    
    if (isnan(amount) || isinf(amount))
    {
        _lblMonthlyPayment.font = [UIFont boldSystemFontOfSize:18];
        _lblMonthlyPayment.textColor = [UIColor redColor];
        _lblMonthlyPayment.text = @"You must enter all required fields.";
    }
    else
    {
        _lblMonthlyPayment.font = [UIFont fontWithName:@"Avenir Next" size:28];
        _lblMonthlyPayment.textColor = [UIColor whiteColor];
        _lblMonthlyPayment.text = [NSString stringWithFormat:@"%@",[NSString stringWithFormat:@"%.02f", amount]];
    }
    
    [self speak:_lblMonthlyPayment.text];
}

-(void)speak:(NSString *)words
{
    if (_sound) {
        AVSpeechSynthesizer *synthesizer = [[AVSpeechSynthesizer alloc] init];
        AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:words];
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate;
        [synthesizer speakUtterance:utterance];
    }
}

-(float)calculatPMTWithRatePerPeriod:(double)ratePerPeriod
                    numberOfPayments:(NSInteger)numberOfPayments
                          loanAmount:(double)loanAmount
                         futureValue:(double)futureValue
                                type:(NSInteger)type
{
    
    double q;
    
    q = pow(1 + ratePerPeriod, numberOfPayments);
    
    return (ratePerPeriod * (futureValue + (q * loanAmount))) / ((-1 + q) * (1 + ratePerPeriod * (type)));
    
}

-(IBAction)setSound:(id)sender on:(bool)on
{
    if (on || !_sound) {
        UIImage *image = [UIImage imageNamed:@"SoundOn.png"];
        _sound = true;
        [_buttonSound setImage:image forState:UIControlStateNormal];
    } else {
        UIImage *image = [UIImage imageNamed:@"SoundOff.png"];
        _sound = false;
        [_buttonSound setImage:image forState:UIControlStateNormal];
    }
}

@end
