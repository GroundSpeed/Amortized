//
//  PAYViewController.h
//  EZ Payment Calculator
//
//  Created by Don Miller on 1/31/13.
//  Copyright (c) 2013 GroundSpeed™. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PAYInputsTableViewController.h"
#include "Math.h"

@interface PAYViewController : UIViewController <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UILabel *lblMonthlyPayment;
@property (strong,nonatomic) PAYInputsTableViewController *tVC;

-(float)calculatPMTWithRatePerPeriod:(double)ratePerPeriod
                    numberOfPayments:(NSInteger)numberOfPayments
                          loanAmount:(double)loanAmount
                         futureValue:(double)futureValue
                                type:(NSInteger)type;

- (IBAction)btnCalculate:(id)sender;

@end

