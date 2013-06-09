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
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(loadTextFields) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
}

- (void)loadTextFields
{
    if ([self connected])
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
        
        _internetStatus = @"Internet connected";

    }
    else
    {
        _thirtyYearFixedToday.text = @"N/A";
        _thirtyYearFixedLastWeek.text = @"N/A";
        _fifteenYearFixedToday.text = @"N/A";
        _fifteenYearFixedLastWeek.text = @"N/A";
        _fiveOneArmToday.text = @"N/A";
        _fiveOneArmLastWeek.text = @"N/A";
        
        _internetStatus = @"There is no connection to the internet";
    }
    
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];    
    
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
    tempLabel.textColor = [UIColor whiteColor]; //here you can change the text color of header.
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
    
    UILabel *tempLabel=[[UILabel alloc]initWithFrame:CGRectMake(20, 0, tableView.bounds.size.width, 30)];
    tempLabel.backgroundColor=[UIColor clearColor];
    tempLabel.textColor = [UIColor darkGrayColor]; //here you can change the text color of header.
    tempLabel.font = [UIFont italicSystemFontOfSize:16];
    
    if (section ==0)
        tempLabel.text=@"";
    else if (section == 1)
        tempLabel.text=_internetStatus;
    
    [tempView addSubview:tempLabel];
    
    return tempView;
}

- (BOOL)connected
{
    NSURL *scriptUrl = [NSURL URLWithString:@"http://www.google.com"];
    NSData *data = [NSData dataWithContentsOfURL:scriptUrl];
    if (data)
        return true;
    else
        return false;
}

@end
