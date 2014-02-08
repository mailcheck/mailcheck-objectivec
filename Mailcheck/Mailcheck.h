//
//  Mailcheck.h
//  Frost
//
//  Created by David Kasper on 1/3/13.
//  Licensed under the MIT License.
//

#import <Foundation/Foundation.h>

@interface Mailcheck : NSObject

+(NSDictionary *)suggest:(NSString *)email;
+(NSDictionary *)suggest:(NSString *)email extraDomains:(NSArray *)domains extraTopLevelDomains:(NSArray *)topLevelDomains;
+(NSDictionary *)suggest:(NSString *)email domains:(NSArray *)domains topLevelDomains:(NSArray *)topLevelDomains;

//new interface that includes email validity checking
+(NSDictionary *)check:(NSString *)email;
+(NSDictionary *)check:(NSString *)email extraDomains:(NSArray *)domains extraTopLevelDomains:(NSArray *)topLevelDomains;
+(NSDictionary *)check:(NSString *)email domains:(NSArray *)domains topLevelDomains:(NSArray *)topLevelDomains;

@end
