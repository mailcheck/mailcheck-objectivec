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
    
    self.checkButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.checkButton setTitle:@"Check" forState:UIControlStateNormal];
    [self.checkButton addTarget:self action:@selector(check:) forControlEvents:UIControlEventTouchUpInside];
    self.checkButton.frame = CGRectMake(20, 60, 280, 40);
    [self.window addSubview:self.checkButton];
    
    self.resultLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 110, 280, 20)];
    [self.window addSubview:self.resultLabel];
    
    [self.window makeKeyAndVisible];
    return YES;
}

-(void)check:(id)sender {
    NSDictionary *result = [Mailcheck suggest:self.textField.text];
    if (result) {
        self.resultLabel.text = [NSString stringWithFormat:@"Did you mean %@?", result[@"full"]];
    } else {
        self.resultLabel.text = @"No suggestion found";
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
