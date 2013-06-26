//
//  PAYDaysSinceDateViewController.h
//  Pay Calc
//
//  Created by Don Miller on 6/25/13.
//  Copyright (c) 2013 GroundSpeed. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PAYDaysSinceDateViewController : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *lblTotalDays;
@property (strong, nonatomic) IBOutlet UITextField *txtFromDate;

-(IBAction)btnCalculate:(id)sender;
-(UIToolbar*)keyboardHeader;

-(void) getDaysFromDate;
-(void) cancelNumberPad;
-(void) doneWithNumberPad;

@end
