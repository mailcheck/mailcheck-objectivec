//
//  AppDelegate.h
//  MailcheckDemo
//
//  Created by David Kasper on 1/3/13.
//  Copyright (c) 2013 David Kasper. All rights reserved.
//  Licensed under the MIT License.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UITextField *textField;
@property (strong, nonatomic) UIButton *checkButton;
@property (strong, nonatomic) UILabel *resultLabel;
@property (strong, nonatomic) UILabel *thresholdLabel;
@property (strong, nonatomic) UIStepper *thresholdStepper;

@end
