//
//  PAYRateTabelViewController.h
//  Pay Calc
//
//  Created by Don Miller on 5/21/13.
//  Copyright (c) 2013 GroundSpeed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InterestRates.h"

@interface PAYRateTabelViewController : UITableViewController

@property (strong, nonatomic) NSDictionary *dictInterestRates;
@property (strong, nonatomic) IBOutlet UITableViewController *tableController;

-(void)loadTextFields;

@end
