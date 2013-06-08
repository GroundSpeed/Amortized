//
//  PAYRateTabelViewController.m
//  Pay Calc
//
//  Created by Don Miller on 5/21/13.
//  Copyright (c) 2013 GroundSpeed. All rights reserved.
//

#import "PAYRateTableViewController.h"

@interface PAYRateTableViewController ()

@end

@implementation PAYRateTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadTextFields];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)loadTextFields
{
    NSString *percentSign = @"%";
    InterestRates *ir = [[InterestRates alloc] init];
    _dictInterestRates = [ir getInterestRates];
    _thirtyYearFixedToday.text = [NSString stringWithFormat:@"%@%@", [_dictInterestRates objectForKey:@"thirtyYearFixedToday"], percentSign];
    _thirtyYearFixedLastWeek.text = [NSString stringWithFormat:@"%@%@", [_dictInterestRates objectForKey:@"thirtyYearFixedLastWeek"], percentSign];
    _fifteenYearFixedToday.text = [NSString stringWithFormat:@"%@%@", [_dictInterestRates objectForKey:@"fifteenYearFixedToday"], percentSign];
    _fifteenYearFixedLastWeek.text = [NSString stringWithFormat:@"%@%@", [_dictInterestRates objectForKey:@"fifteenYearFixedLastWeek"], percentSign];
    _fiveOneArmToday.text = [NSString stringWithFormat:@"%@%@", [_dictInterestRates objectForKey:@"fiveOneARMToday"], percentSign];
    _fiveOneArmLastWeek.text = [NSString stringWithFormat:@"%@%@", [_dictInterestRates objectForKey:@"fiveOneARMLastWeek"], percentSign];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
