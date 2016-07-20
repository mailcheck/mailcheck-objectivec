//
//  Mailcheck.m
//  Frost
//
//  Created by David Kasper on 1/3/13.
//  Licensed under the MIT License.
//

#import "Mailcheck.h"
#import <NSString-Email/NSString+Email.h>

@implementation Mailcheck

static NSArray *defaultDomains, *defaultTopLevelDomains;
static NSInteger threshold;

+(void)initialize {
    defaultDomains = @[@"yahoo.com", @"google.com", @"hotmail.com", @"gmail.com", @"me.com", @"aol.com", @"mac.com", @"live.com", @"comcast.net", @"googlemail.com", @"msn.com", @"hotmail.co.uk", @"yahoo.co.uk", @"facebook.com", @"verizon.net", @"sbcglobal.net", @"att.net", @"gmx.com", @"mail.com"];
        
    defaultTopLevelDomains = @[@"co.uk", @"com", @"net", @"org", @"info", @"edu", @"gov", @"mil"];
    threshold = 3;
}

+(void)setThreshold:(NSInteger)newThreshold {
    threshold = newThreshold;
}

+(NSDictionary *)check:(NSString *)email {
    return [self check:email domains:defaultDomains topLevelDomains:defaultTopLevelDomains];
}

+(NSDictionary *)check:(NSString *)email extraDomains:(NSArray *)domains extraTopLevelDomains:(NSArray *)topLevelDomains {
    return [self check:email domains:[defaultDomains arrayByAddingObjectsFromArray:domains] topLevelDomains:[defaultTopLevelDomains arrayByAddingObjectsFromArray:topLevelDomains]];
}

+(NSDictionary *)check:(NSString *)email domains:(NSArray *)domains topLevelDomains:(NSArray *)topLevelDomains {
    NSDictionary *suggestion = [self suggest:email domains:domains topLevelDomains:topLevelDomains];
    if(suggestion) {
        return @{@"valid": @([email isEmail]), @"suggestion": suggestion};
    }
    return @{@"valid": @([email isEmail])};
}

+(NSDictionary *)suggest:(NSString *)email {
    return [self suggest:email domains:defaultDomains topLevelDomains:defaultTopLevelDomains];
}

+(NSDictionary *)suggest:(NSString *)email extraDomains:(NSArray *)domains extraTopLevelDomains:(NSArray *)topLevelDomains {
    return [self suggest:email domains:[defaultDomains arrayByAddingObjectsFromArray:domains] topLevelDomains:[defaultTopLevelDomains arrayByAddingObjectsFromArray:topLevelDomains]];
}

+(NSDictionary *)suggest:(NSString *)email domains:(NSArray *)domains topLevelDomains:(NSArray *)topLevelDomains {
    email = [email lowercaseString];
    NSDictionary *emailParts = [self splitEmail:email];
    
    if(emailParts) {
        NSString *closestDomain = [self findClosestDomain:emailParts[@"domain"] domains:domains];
        if(closestDomain && ![closestDomain isEqualToString:emailParts[@"domain"]]) {
            return @{@"address": emailParts[@"address"], @"domain": closestDomain, @"full": [emailParts[@"address"] stringByAppendingFormat:@"@%@",closestDomain]};
        } else {
            NSString *closestTopLevelDomain = [self findClosestDomain:emailParts[@"topLevelDomain"] domains:topLevelDomains];
            if(emailParts[@"domain"] && closestTopLevelDomain && ![closestTopLevelDomain isEqualToString:emailParts[@"topLevelDomain"]]) {
                NSString *domain = emailParts[@"domain"];
                NSRange lastRange = [domain rangeOfString:emailParts[@"topLevelDomain"] options:NSBackwardsSearch];
                closestDomain = [[domain substringWithRange:NSMakeRange(0, MIN(domain.length, lastRange.location))] stringByAppendingString:closestTopLevelDomain];
                return @{@"address": emailParts[@"address"], @"domain": closestDomain, @"full": [emailParts[@"address"] stringByAppendingFormat:@"@%@",closestDomain]};
            }
        }
    }
    
    return nil;
}

+(NSString *)findClosestDomain:(NSString *)domain domains:(NSArray *)domains {
    NSInteger dist;
    NSInteger minDist = 99;
    NSString *closestDomain = nil;
    
    if (!domain || !domains) {
        return nil;
    }
    
    for(NSString *targetDomain in domains) {
        if ([domain isEqualToString:targetDomain]) {
            return domain;
        }
        dist = [self sift3Distance:domain :targetDomain];
        if (dist < minDist) {
            minDist = dist;
            closestDomain = targetDomain;
        }
    }
    
    if (minDist <= threshold && closestDomain) {
        return closestDomain;
    } else {
        return nil;
    }
}

+(NSInteger)sift3Distance:(NSString *)s1 :(NSString *)s2 {
    // sift3: http://siderite.blogspot.com/2007/04/super-fast-and-accurate-string-distance.html
    if (!s1 || [s1 length] == 0) {
        if (!s2 || [s2 length] == 0) {
            return 0;
        } else {
            return [s2 length];
        }
    }
    
    if (!s2 || [s2 length] == 0) {
        return [s1 length];
    }
    
    NSInteger c = 0;
    NSInteger offset1 = 0;
    NSInteger offset2 = 0;
    NSInteger lcs = 0;
    NSInteger maxOffset = 5;
    
    while ((c + offset1 < [s1 length]) && (c + offset2 < [s2 length])) {
        if ([s1 characterAtIndex:c+offset1] == [s2 characterAtIndex:c + offset2]) {
            lcs++;
        } else {
            offset1 = 0;
            offset2 = 0;
            for (NSInteger i = 0; i < maxOffset; i++) {
                if ((c + i < [s1 length]) && ([s1 characterAtIndex:(c + i)] == [s2 characterAtIndex:c])) {
                    offset1 = i;
                    break;
                }
                if ((c + i < [s2 length]) && ([s2 characterAtIndex:(c + i)] == [s1 characterAtIndex:c])) {
                    offset2 = i;
                    break;
                }
            }
        }
        c++;
    }
    return ([s1 length] + [s2 length]) /2 - lcs;
}

+(NSDictionary *)splitEmail:(NSString *)email {
    NSMutableArray *parts = [[email componentsSeparatedByString:@"@"] mutableCopy];
    
    if ([parts count] < 2) {
        return nil;
    }
    
    for (NSInteger i = 0; i < [parts count]; i++) {
        if ([parts[i] isEqualToString:@""]) {
            return nil;
        }
    }
    
    NSString *domain = [parts lastObject];
    [parts removeLastObject];
    NSArray *domainParts = [domain componentsSeparatedByString:@"."];
    NSString *tld = @"";
    
    if ([domainParts count] == 0) {
        // The address does not have a top-level domain
        return nil;
    } else if ([domainParts count] == 1) {
        // The address has only a top-level domain (valid under RFC)
        tld = domainParts[0];
    } else {
        // The address has a domain and a top-level domain
        for (NSInteger i = 1; i < [domainParts count]; i++) {
            tld = [tld stringByAppendingFormat:@"%@.",domainParts[i]];
        }
        if ([domainParts count] >= 2) {
            tld = [tld substringWithRange:NSMakeRange(0, [tld length] - 1)];
        }
    }
    
    return @{
        @"topLevelDomain": tld,
        @"domain": domain,
        @"address": [parts componentsJoinedByString:@"@"]
    };
}

@end
