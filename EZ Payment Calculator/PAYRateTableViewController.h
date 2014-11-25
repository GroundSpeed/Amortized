//
//  PAYRateTabelViewController.h
//  Pay Calc
//
//  Created by Don Miller on 5/21/13.
//  Copyright (c) 2013 GroundSpeed. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InterestRates.h"

@interface PAYRateTableViewController : UITableViewController

@property (strong, nonatomic) NSDictionary *dictInterestRates;
@property (strong, nonatomic) IBOutlet UITableViewController *tableController;

@property (strong, nonatomic) IBOutlet UILabel *thirtyYearFixedToday;
@property (strong, nonatomic) IBOutlet UILabel *fifteenYearFixedToday;
@property (strong, nonatomic) IBOutlet UILabel *fiveOneArmToday;
@property (strong, nonatomic) IBOutlet UILabel *thirtyYearFixedLastWeek;
@property (strong, nonatomic) IBOutlet UILabel *fifteenYearFixedLastWeek;
@property (strong, nonatomic) IBOutlet UILabel *fiveOneArmLastWeek;

@property (strong, nonatomic) NSString *internetStatus;

-(void) loadTextFields;
-(BOOL) connected;

@end
