//
//  InterestRates.m
//  Pay Calc
//
//  Created by Don Miller on 5/19/13.
//  Copyright (c) 2013 GroundSpeed. All rights reserved.
//

#import "InterestRates.h"

@implementation InterestRates

-(NSDictionary *)getInterestRates
{
    // Variable to store our API Key
    NSString* const API_KEY = @"X1-ZWz1bim5o6gxsb_5i268";
    NSString* searchURL = [NSString
                           stringWithFormat:@"http://www.zillow.com/webservice/GetRateSummary.htm?zws-id=%@&output=json",
                           API_KEY];
    
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
            return nil;
        }
        
        arrayInterestRates = [[NSMutableArray alloc] init];
        arrayInterestLabels = [[NSMutableArray alloc] init];
        
        NSDictionary *dictInterest = jsonObjects[@"response"];
        
        // TODAY
        NSDictionary *today = dictInterest[@"today"];
        
        NSString *thirtyYearFixedToday = today[@"thirtyYearFixed"];
        [arrayInterestRates addObject:thirtyYearFixedToday];
        [arrayInterestLabels addObject:@"thirtyYearFixedToday"];
        
        NSString *fifteenYearFixedToday = today[@"fifteenYearFixed"];
        [arrayInterestRates addObject:fifteenYearFixedToday];
        [arrayInterestLabels addObject:@"fifteenYearFixedToday"];
        
        NSString *fiveOneARMToday = today[@"fiveOneARM"];
        [arrayInterestRates addObject:fiveOneARMToday];
        [arrayInterestLabels addObject:@"fiveOneARMToday"];
        
        // LAST WEEK
        NSDictionary *lastWeek = dictInterest[@"lastWeek"];
        
        NSString *thirtyYearFixedLastWeek = lastWeek[@"thirtyYearFixed"];
        [arrayInterestRates addObject:thirtyYearFixedLastWeek];
        [arrayInterestLabels addObject:@"thirtyYearFixedLastWeek"];
        
        NSString *fifteenYearFixedLastWeek = lastWeek[@"fifteenYearFixed"];
        [arrayInterestRates addObject:fifteenYearFixedLastWeek];
        [arrayInterestLabels addObject:@"fifteenYearFixedLastWeek"];
        
        NSString *fiveOneARMLastWeek = lastWeek[@"fiveOneARM"];
        [arrayInterestRates addObject:fiveOneARMLastWeek];
        [arrayInterestLabels addObject:@"fiveOneARMLastWeek"];
        
        NSDictionary *dictReturn = [[NSDictionary alloc] initWithObjects:arrayInterestRates
                                                                 forKeys:arrayInterestLabels];
        
        return dictReturn;
    }
    else
    {
        return nil;
    }
}

@end
