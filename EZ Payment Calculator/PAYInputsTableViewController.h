//
//  PAYInputsTableViewController.h
//  Pay Calc
//
//  Created by Don Miller on 6/8/13.
//  Copyright (c) 2013 GroundSpeed. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PAYInputsTableViewController : UITableViewController

@property (strong, nonatomic) IBOutlet UITextField *txtAmount;
@property (strong, nonatomic) IBOutlet UITextField *txtDownPayment;
@property (strong, nonatomic) IBOutlet UITextField *txtInterestRate;
@property (strong, nonatomic) IBOutlet UITextField *txtTerm;

-(void) hideKeyboard;

@end
