//
//  PAYAppDelegate.h
//  EZ Payment Calculator
//
//  Created by Don Miller on 1/31/13.
//  Copyright (c) 2013 GroundSpeed. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AMSlideOutNavigationController;

@interface PAYAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) AMSlideOutNavigationController*	slideoutController;

@end
