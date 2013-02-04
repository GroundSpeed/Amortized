//
//  PAYViewController.h
//  EZ Payment Calculator
//
//  Created by Don Miller on 1/31/13.
//  Copyright (c) 2013 GroundSpeed™. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PAYViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITextField *txtAmount;
@property (strong, nonatomic) IBOutlet UITextField *txtDownPayment;
@property (strong, nonatomic) IBOutlet UITextField *txtInterestRate;
@property (strong, nonatomic) IBOutlet UILabel *lblPMI;
@property (strong, nonatomic) IBOutlet UITextField *txtPMI;
@property (strong, nonatomic) IBOutlet UITextField *txtMonthlyPayment;
@property (strong, nonatomic) IBOutlet UIPickerView *pickRates;

@property (strong, nonatomic) NSMutableArray *arrayInterestRates;
@property (strong, nonatomic) NSMutableArray *arrayInterestLabels;

- (IBAction)scHomeOther:(id)sender;
- (IBAction)btnCalculate:(id)sender;
- (void)getInterestRates;

@end

