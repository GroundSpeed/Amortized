//
//  PAYAppDelegate.m
//  EZ Payment Calculator
//
//  Created by Don Miller on 1/31/13.
//  Copyright (c) 2013 GroundSpeed. All rights reserved.
//

#import "PAYAppDelegate.h"
#import "AMSlideOutNavigationController.h"

@implementation PAYAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    
	UIViewController* controller;
	
	self.slideoutController = [AMSlideOutNavigationController slideOutNavigation];
	
	[self.slideoutController addSectionWithTitle:@"Main Menu"];
	
	controller = [storyboard instantiateViewControllerWithIdentifier:@"PAYCalcAmortController"];
	[self.slideoutController addViewControllerToLastSection:controller tagged:1 withTitle:@"Monthly Payment" andIcon:@""];
	
	controller = [storyboard instantiateViewControllerWithIdentifier:@"PAYShowRateController"];
	[self.slideoutController addViewControllerToLastSection:controller tagged:2 withTitle:@"Current Mortgage Rates" andIcon:@""];

    controller = [storyboard instantiateViewControllerWithIdentifier:@"PAYSettingsController"];
	[self.slideoutController addViewControllerToLastSection:controller tagged:3 withTitle:@"Settings" andIcon:@""];

    [self.window setRootViewController:self.slideoutController];
	
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
