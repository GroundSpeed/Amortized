//
//  PAYDaysSinceDateViewController.m
//  Pay Calc
//
//  Created by Don Miller on 6/25/13.
//  Copyright (c) 2013 GroundSpeed. All rights reserved.
//

#import "PAYDaysSinceDateViewController.h"

@interface PAYDaysSinceDateViewController ()

@end

@implementation PAYDaysSinceDateViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _txtFromDate.placeholder = [self getDateFromDays:28];
    _txtFromDate.keyboardType = UIKeyboardTypeDecimalPad;
    _txtFromDate.inputAccessoryView = [self keyboardHeader];
}

-(NSString *)getDateFromDays:(int)days
{
    // Dynamicall add placeholder for freshness
    NSDate *today = [NSDate date];
    NSDate *placeHolder = [today dateByAddingTimeInterval:-days*24*60*60];
    NSDateFormatter *df = [[NSDateFormatter alloc]init];
    [df setDateFormat:@"MM.dd.yyyy"];
    return [NSString stringWithFormat:@"%@", [df stringFromDate:placeHolder]];
}

-(UIToolbar*)keyboardHeader
{
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.barStyle = UIBarStyleBlackTranslucent;
    
    numberToolbar.items = [NSArray arrayWithObjects:
                           [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelNumberPad)],
                           [[UIBarButtonItem alloc]initWithTitle:@"Clear" style:UIBarButtonItemStyleBordered target:self action:@selector(clearNumberPad)],
                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           [[UIBarButtonItem alloc]initWithTitle:@"Calculate" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithNumberPad)],
                           nil];
    
    [numberToolbar sizeToFit];
    
    return numberToolbar;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    if (touch != nil)
    {
        [_txtFromDate resignFirstResponder];
    }
}

-(IBAction)btnCalculate:(id)sender
{
    [self getDaysFromDate];
}

-(void) getDaysFromDate
{
    NSDateFormatter *df = [[NSDateFormatter alloc]init];
    [df setDateFormat:@"MM.dd.yyyy"];
    
    NSDate *date1 = [df dateFromString:_txtFromDate.text];
    NSDate *date2 = [NSDate date];
    
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSUInteger unitFlags = NSDayCalendarUnit;
    
    NSDateComponents *components = [gregorian components:unitFlags
                                                fromDate:date1
                                                  toDate:date2 options:0];
    
    _lblTotalDays.text = [NSString stringWithFormat:@"%i Days", [components day]];
}

#pragma mark Added Cancel Apply to Keyboard

-(void)clearNumberPad
{
    _txtFromDate.text = @"";
}

-(void)cancelNumberPad
{
    [_txtFromDate resignFirstResponder];
}

-(void)doneWithNumberPad
{
    [_txtFromDate resignFirstResponder];
    [self getDaysFromDate];
}


@end
