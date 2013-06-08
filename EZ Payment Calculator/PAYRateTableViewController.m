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

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *tempView=[[UIView alloc]initWithFrame:CGRectMake(0,200,300,244)];
    tempView.backgroundColor=[UIColor clearColor];
    
    UILabel *tempLabel=[[UILabel alloc]initWithFrame:CGRectMake(15,0,300,44)];
    tempLabel.backgroundColor=[UIColor clearColor];
    tempLabel.textColor = [UIColor blackColor]; //here you can change the text color of header.
    tempLabel.font = [UIFont boldSystemFontOfSize:20];

    if (section ==0)
        tempLabel.text=@"Today";
    else if (section == 1)
        tempLabel.text=@"Last Week";
    
    [tempView addSubview:tempLabel];
    
    return tempView;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *tempView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
    tempView.backgroundColor=[UIColor clearColor];
    
    UILabel *tempLabel=[[UILabel alloc]initWithFrame:CGRectMake(60, 0, tableView.bounds.size.width, 30)];
    tempLabel.backgroundColor=[UIColor clearColor];
    tempLabel.textColor = [UIColor darkGrayColor]; //here you can change the text color of header.
    tempLabel.font = [UIFont italicSystemFontOfSize:16];
    
    if (section ==0)
        tempLabel.text=@"";
    else if (section == 1)
        tempLabel.text=@"";
    
    [tempView addSubview:tempLabel];
    
    return tempView;
}

@end
