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
    
    //NSLog(@"%@", searchURL);
    
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
        
        NSDictionary *dictInterest = [jsonObjects objectForKey:@"response"];
        //NSLog(@"dictInterest %@", dictInterest);
        
        // TODAY
        NSDictionary *today = [dictInterest objectForKey:@"today"];
        //NSLog(@"today %@", today);
        
        NSString *thirtyYearFixedToday = [today objectForKey:@"thirtyYearFixed"];
        //NSLog(@"thirtyYearFixed %@", thirtyYearFixedToday);
        [arrayInterestRates addObject:thirtyYearFixedToday];
        [arrayInterestLabels addObject:@"thirtyYearFixedToday"];
        
        NSString *fifteenYearFixedToday = [today objectForKey:@"fifteenYearFixed"];
        //NSLog(@"fifteenYearFixed %@", fifteenYearFixedToday);
        [arrayInterestRates addObject:fifteenYearFixedToday];
        [arrayInterestLabels addObject:@"fifteenYearFixedToday"];
        
        NSString *fiveOneARMToday = [today objectForKey:@"fiveOneARM"];
        //NSLog(@"fiveOneARM %@", fiveOneARMToday);
        [arrayInterestRates addObject:fiveOneARMToday];
        [arrayInterestLabels addObject:@"fiveOneARMToday"];
        
        // LAST WEEK
        NSDictionary *lastWeek = [dictInterest objectForKey:@"lastWeek"];
        //NSLog(@"today %@", lastWeek);
        
        NSString *thirtyYearFixedLastWeek = [lastWeek objectForKey:@"thirtyYearFixed"];
        //NSLog(@"thirtyYearFixedLastWeek %@", thirtyYearFixedLastWeek);
        [arrayInterestRates addObject:thirtyYearFixedLastWeek];
        [arrayInterestLabels addObject:@"thirtyYearFixedLastWeek"];
        
        NSString *fifteenYearFixedLastWeek = [lastWeek objectForKey:@"fifteenYearFixed"];
        //NSLog(@"fifteenYearFixedLastWeek %@", fifteenYearFixedLastWeek);
        [arrayInterestRates addObject:fifteenYearFixedLastWeek];
        [arrayInterestLabels addObject:@"fifteenYearFixedLastWeek"];
        
        NSString *fiveOneARMLastWeek = [lastWeek objectForKey:@"fiveOneARM"];
        //NSLog(@"fiveOneARMLastWeek %@", fiveOneARMLastWeek);
        [arrayInterestRates addObject:fiveOneARMLastWeek];
        [arrayInterestLabels addObject:@"fiveOneARMLastWeek"];
        
        NSDictionary *dictReturn = [[NSDictionary alloc] initWithObjects:arrayInterestRates forKeys:arrayInterestLabels];
        
        //NSLog(@"arrayInterestRates %@", arrayInterestRates);
        //NSLog(@"arrayInterestLabels %@", arrayInterestLabels);
        //NSLog(@"dictReturn %@", dictReturn);
        return dictReturn;
    }
    else
    {
        // Handle Error
        return nil;
    }
}

@end
