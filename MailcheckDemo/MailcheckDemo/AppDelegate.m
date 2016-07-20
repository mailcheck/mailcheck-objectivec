//
//  AppDelegate.m
//  MailcheckDemo
//
//  Created by David Kasper on 1/3/13.
//  Copyright (c) 2013 David Kasper. All rights reserved.
//  Licensed under the MIT License.
//

#import "AppDelegate.h"
#import "Mailcheck.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    
    self.textField = [[UITextField alloc] initWithFrame:CGRectMake(20, 30, 280, 20)];
    self.textField.placeholder = @"test@example.com";
    [self.window addSubview:self.textField];
    
    self.thresholdLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(self.textField.frame) + 15, 200, 20)];
    self.thresholdStepper = [[UIStepper alloc] initWithFrame:CGRectMake(220, CGRectGetMaxY(self.textField.frame) + 10, 94, 20)];
    self.thresholdStepper.value = 3;
    [self.thresholdStepper addTarget:self action:@selector(step:) forControlEvents:UIControlEventValueChanged];
    self.thresholdLabel.text = [NSString stringWithFormat:@"Threshold: %d", (int)self.thresholdStepper.value];
    [self.window addSubview:self.thresholdLabel];
    [self.window addSubview:self.thresholdStepper];
    
    self.checkButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.checkButton setTitle:@"Check" forState:UIControlStateNormal];
    [self.checkButton addTarget:self action:@selector(check:) forControlEvents:UIControlEventTouchUpInside];
    self.checkButton.frame = CGRectMake(20, CGRectGetMaxY(self.thresholdStepper.frame) + 10, 280, 40);
    [self.window addSubview:self.checkButton];
    
    self.resultLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(self.checkButton.frame) + 10, 280, 60)];
    self.resultLabel.numberOfLines = 3;
    [self.window addSubview:self.resultLabel];
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)step:(id)sender {
    [Mailcheck setThreshold:self.thresholdStepper.value];
    self.thresholdLabel.text = [NSString stringWithFormat:@"Threshold: %d", (int)self.thresholdStepper.value];
}

-(void)check:(id)sender {
    NSDictionary *result = [Mailcheck check:self.textField.text extraDomains:nil extraTopLevelDomains:nil];
    if (result[@"suggestion"]) {
        self.resultLabel.text = [NSString stringWithFormat:@"Did you mean %@?.\nValid: %d", result[@"suggestion"][@"full"], [result[@"valid"] boolValue]];
    } else {
        self.resultLabel.text = [NSString stringWithFormat:@"No suggestion found.\nValid email: %d", [result[@"valid"] boolValue]];
    }
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
