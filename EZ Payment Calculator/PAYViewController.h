//
//  PAYViewController.h
//  EZ Payment Calculator
//
//  Created by Don Miller on 1/31/13.
//  Copyright (c) 2013 GroundSpeed™. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PAYViewController : UIViewController <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *txtAmount;
@property (strong, nonatomic) IBOutlet UITextField *txtDownPayment;
@property (strong, nonatomic) IBOutlet UITextField *txtInterestRate;
@property (strong, nonatomic) IBOutlet UILabel *lblPMI;
@property (strong, nonatomic) IBOutlet UITextField *txtPMI;
@property (strong, nonatomic) IBOutlet UILabel *lblMonthlyPayment;
@property (strong, nonatomic) IBOutlet UITextField *txtTerm;
@property (strong, nonatomic) IBOutlet UIPickerView *pickTerms;

-(float)calculatPMTWithRatePerPeriod:(double)ratePerPeriod
                    numberOfPayments:(NSInteger)numberOfPayments
                          loanAmount:(double)loanAmount
                         futureValue:(double)futureValue
                                type:(NSInteger)type;

- (IBAction)scHomeOther:(id)sender;
- (IBAction)btnCalculate:(id)sender;

@end

