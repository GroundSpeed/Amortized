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
    _txtDownPayment.keyboardType = UIKeyboardTypeDecimalPad;
    _txtInterestRate.keyboardType = UIKeyboardTypeDecimalPad;
    _txtTerm.keyboardType = UIKeyboardTypeNumberPad;

}

-(void) hideKeyboard
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

@end
