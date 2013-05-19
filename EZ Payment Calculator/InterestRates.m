//
//  InterestRates.m
//  Pay Calc
//
//  Created by Don Miller on 5/19/13.
//  Copyright (c) 2013 GroundSpeed. All rights reserved.
//

#import "InterestRates.h"

@implementation InterestRates

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
