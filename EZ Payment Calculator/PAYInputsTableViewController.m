//
//  PAYInputsTableViewController.m
//  Pay Calc
//
//  Created by Don Miller on 6/8/13.
//  Copyright (c) 2013 GroundSpeed. All rights reserved.
//

#import "PAYInputsTableViewController.h"

@interface PAYInputsTableViewController ()

@end

@implementation PAYInputsTableViewController
@synthesize delegate;

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
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.tableView addGestureRecognizer:gestureRecognizer];

    // Set numeric keypads with decimal points
    _txtAmount.keyboardType = UIKeyboardTypeDecimalPad;
    _txtAmount.inputAccessoryView = [self keyboardHeader];        // Amount Cancel Apply Button
    _txtDownPayment.keyboardType = UIKeyboardTypeDecimalPad;
    _txtDownPayment.inputAccessoryView = [self keyboardHeader];   // Down Payment Cancel Apply Button
    _txtInterestRate.keyboardType = UIKeyboardTypeDecimalPad;
    _txtInterestRate.inputAccessoryView = [self keyboardHeader];  // Interest Rate Cancel Apply Button
    _txtTerm.keyboardType = UIKeyboardTypeNumberPad;
    _txtTerm.inputAccessoryView = [self keyboardHeader];          // Term Cancel Apply Button
}


-(UIToolbar*)keyboardHeader
{
    UIToolbar* numberToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    numberToolbar.barStyle = UIBarStyleDefault;
    
    numberToolbar.items = [NSArray arrayWithObjects:
                               [[UIBarButtonItem alloc]initWithTitle:@" < "
                                                               style:UIBarButtonItemStyleBordered
                                                              target:self action:@selector(previousField)],
                               [[UIBarButtonItem alloc]initWithTitle:@"   > "
                                                           style:UIBarButtonItemStyleBordered
                                                          target:self action:@selector(nextField)],
                               [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                               [[UIBarButtonItem alloc]initWithTitle:@"[Calculate]"
                                                               style:UIBarButtonItemStyleDone
                                                              target:self action:@selector(doneWithNumberPad)],
                               nil];
    
    [numberToolbar sizeToFit];
    
    return numberToolbar;
}

-(void)hideKeyboard
{
    [_txtAmount resignFirstResponder];
    [_txtDownPayment resignFirstResponder];
    [_txtInterestRate resignFirstResponder];
    [_txtTerm resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Added Cancel Apply to Keyboard

-(void)cancelNumberPad
{
    [self hideKeyboard];
}

-(void)doneWithNumberPad
{
    [self hideKeyboard];
    [self.delegate getMonthlyPayment];
}

-(void) previousField
{
    if ([_txtAmount isFirstResponder])
        [_txtTerm becomeFirstResponder];
    else if ([_txtDownPayment isFirstResponder])
        [_txtAmount becomeFirstResponder];
    else if ([_txtInterestRate isFirstResponder])
        [_txtDownPayment becomeFirstResponder];
    else if ([_txtTerm isFirstResponder])
        [_txtInterestRate becomeFirstResponder];
}


-(void) nextField
{
    if ([_txtAmount isFirstResponder])
        [_txtDownPayment becomeFirstResponder];
    else if ([_txtDownPayment isFirstResponder])
        [_txtInterestRate becomeFirstResponder];
    else if ([_txtInterestRate isFirstResponder])
        [_txtTerm becomeFirstResponder];
    else if ([_txtTerm isFirstResponder])
        [_txtAmount becomeFirstResponder];
}


@end
