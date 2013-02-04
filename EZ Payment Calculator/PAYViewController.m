//
//  PAYViewController.m
//  EZ Payment Calculator
//
//  Created by Don Miller on 1/31/13.
//  Copyright (c) 2013 GroundSpeed™. All rights reserved.
//

#import "PAYViewController.h"

@interface PAYViewController ()

@end

@implementation PAYViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self getInterestRates];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark Actions
- (IBAction)scHomeOther:(id)sender
{
    UISegmentedControl *segmentedControl = (UISegmentedControl *) sender;
    NSInteger selectedSegment = segmentedControl.selectedSegmentIndex;
    
    if (selectedSegment == 0)
    {
        _txtPMI.hidden = false;
        _lblPMI.hidden = false;
    }
    else
    {
        _txtPMI.hidden = true;
        _lblPMI.hidden = true;
    }
}

- (IBAction)btnCalculate:(id)sender
{

}

#pragma mark PickerViewCode

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component
{
    return _arrayInterestRates.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    if(component == 0)
	{
        return [_arrayInterestLabels objectAtIndex:row];
	}
	else if(component == 1)
	{
        return [_arrayInterestRates objectAtIndex:row];
	}

    return nil;
}

- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component
{

}

-(void)getInterestRates
{    
    // Variable to store our API Key
    NSString* const API_KEY = @"X1-ZWz1bim5o6gxsb_5i268";
    NSString* searchURL = [NSString
                           stringWithFormat:@"http://www.zillow.com/webservice/GetRateSummary.htm?zws-id=%@&output=json",
                           API_KEY];
    
    NSLog(@"%@", searchURL);
    
    NSError *error = nil;
    NSData *jsonData = [NSData dataWithContentsOfURL:[NSURL URLWithString:searchURL]];
    
    if (jsonData)
    {
        id jsonObjects = [NSJSONSerialization JSONObjectWithData:jsonData
                                                         options:NSJSONReadingMutableContainers
                                                           error:&error];
        
        if (error)
        {
            NSLog(@"error is %@", [error localizedDescription]);
            
            // Handle Error and return
            return;
        }
        
       	NSDictionary *dictInterest = [jsonObjects objectForKey:@"response"];
        NSLog(@"%@", dictInterest);
        
        NSDictionary *today = [dictInterest objectForKey:@"today"];
        NSLog(@"%@", today);
        
        NSString *thirtyYearFixed = [today objectForKey:@"thirtyYearFixed"];
        NSLog(@"%@", thirtyYearFixed);
        [_arrayInterestRates addObject:thirtyYearFixed];
        [_arrayInterestLabels addObject:@"30 Year Fixed"];

        NSString *fifteenYearFixed = [today objectForKey:@"fifteenYearFixed"];
        NSLog(@"%@", fifteenYearFixed);
        [_arrayInterestRates addObject:fifteenYearFixed];
        [_arrayInterestLabels addObject:@"15 Year Fixed"];
        
        NSString *fiveOneARM = [today objectForKey:@"fiveOneARM"];
        NSLog(@"%@", fiveOneARM);
        [_arrayInterestRates addObject:fiveOneARM];
        [_arrayInterestLabels addObject:@"5/1 Year ARM"];        
    }
    else
    {
        // Handle Error
    }
}

@end
