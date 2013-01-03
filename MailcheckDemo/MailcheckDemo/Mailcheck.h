//
//  Mailcheck.h
//  Frost
//
//  Created by David Kasper on 1/3/13.
//  Copyright (c) 2013 Mixbook. All rights reserved.
//  Licensed under the MIT License.
//

#import <Foundation/Foundation.h>

@interface Mailcheck : NSObject

+(NSDictionary *)suggest:(NSString *)email;
+(NSDictionary *)suggest:(NSString *)email domains:(NSArray *)domains topLevelDomains:(NSArray *)topLevelDomains;

@end
