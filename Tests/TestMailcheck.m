//
//  TestMailcheck.m
//  Frost
//
//  Created by David Kasper on 1/3/13.
//  Copyright (c) 2013 Mixbook. All rights reserved.
//  Licensed under the MIT License.
//

#import <GHUnitIOS/GHUnit.h>
#import "Mailcheck.h"

@interface MailcheckTester : Mailcheck
    +(NSString *)findClosestDomain:(NSString *)domain domains:(NSArray *)domains;
    +(NSDictionary *)splitEmail:(NSString *)email;
@end

@implementation MailcheckTester

@end

@interface TestMailcheck : GHTestCase { }
@end

@implementation TestMailcheck

- (void)testValid {
    NSDictionary *result = [Mailcheck suggest:@"david@hotmail.com"];
    GHAssertNil(result, @"nil for valid domain");
}

- (void)testSplitEmail {
    GHAssertEqualObjects([MailcheckTester splitEmail:@"test@example.com"], (@{@"address" : @"test", @"domain": @"example.com", @"topLevelDomain": @"com"}), @"basic");
    GHAssertEqualObjects([MailcheckTester splitEmail:@"test@example.co.uk"], (@{@"address" : @"test", @"domain": @"example.co.uk", @"topLevelDomain": @"co.uk"}), @"co.uk");
    GHAssertEqualObjects([MailcheckTester splitEmail:@"test@mail.randomsmallcompany.co.uk"], (@{@"address" : @"test", @"domain": @"mail.randomsmallcompany.co.uk", @"topLevelDomain": @"randomsmallcompany.co.uk"}), @"randomsmallcompany");
    GHAssertEqualObjects([MailcheckTester splitEmail:@"\"foo@bar\"@example.com"], (@{@"address" : @"\"foo@bar\"", @"domain": @"example.com", @"topLevelDomain": @"com"}), @"foobar");
    GHAssertEqualObjects([MailcheckTester splitEmail:@"containsnumbers1234567890@example.com"], (@{@"address" : @"containsnumbers1234567890", @"domain": @"example.com", @"topLevelDomain": @"com"}), @"basic");
    GHAssertEqualObjects([MailcheckTester splitEmail:@"contains+symbol@example.com"], (@{@"address" : @"contains+symbol", @"domain": @"example.com", @"topLevelDomain": @"com"}), @"+ symbol");
    GHAssertEqualObjects([MailcheckTester splitEmail:@"contains-symbol@example.com"], (@{@"address" : @"contains-symbol", @"domain": @"example.com", @"topLevelDomain": @"com"}), @"- symbol");
    GHAssertEqualObjects([MailcheckTester splitEmail:@"contains.symbol@example.com"], (@{@"address" : @"contains.symbol", @"domain": @"example.com", @"topLevelDomain": @"com"}), @". symbol");
    GHAssertEqualObjects([MailcheckTester splitEmail:@"\"contains.and\\ symbols\"@example.com"], (@{@"address" : @"\"contains.and\\ symbols\"", @"domain": @"example.com", @"topLevelDomain": @"com"}), @". and \\ symbols");
    GHAssertEqualObjects([MailcheckTester splitEmail:@"\"contains.and.@.symbols.com\"@example.com"], (@{@"address" : @"\"contains.and.@.symbols.com\"", @"domain": @"example.com", @"topLevelDomain": @"com"}), @"@ and \\ symbols");
    GHAssertEqualObjects([MailcheckTester splitEmail:@"\"()<>[]:;@,\\\"!#$%&\'*+-/=?^_`{}|^_`{}|~.a\"@allthesymbols.com"], (@{@"address" : @"\"()<>[]:;@,\\\"!#$%&\'*+-/=?^_`{}|^_`{}|~.a\"", @"domain": @"allthesymbols.com", @"topLevelDomain": @"com"}), @"all the symbols");
    GHAssertEqualObjects([MailcheckTester splitEmail:@"postbox@com"], (@{@"address" : @"postbox", @"domain": @"com", @"topLevelDomain": @"com"}), @"basic");
}

- (void)testInvalidEmail {
    GHAssertNil([Mailcheck suggest:@"david@"], @"no domain");
    GHAssertNil([Mailcheck suggest:@"@hotmail.com"], @"no address");
    GHAssertNil([Mailcheck suggest:@"example.com"], @"domain only");
    GHAssertNil([Mailcheck suggest:@"abc.example.com"], @"subdomain only");
    GHAssertNil([MailcheckTester splitEmail:@"david@"], @"no domain");
    GHAssertNil([MailcheckTester splitEmail:@"@hotmail.com"], @"no address");
    GHAssertNil([MailcheckTester splitEmail:@"example.com"], @"domain only");
    GHAssertNil([MailcheckTester splitEmail:@"abc.example.com"], @"subdomain only");
}

- (void)testFindClosestDomain {
    NSArray *defaultDomains = @[@"yahoo.com", @"google.com", @"hotmail.com", @"gmail.com", @"me.com", @"aol.com", @"mac.com", @"live.com", @"comcast.net", @"googlemail.com", @"msn.com", @"hotmail.co.uk", @"yahoo.co.uk", @"facebook.com", @"verizon.net", @"sbcglobal.net", @"att.net", @"gmx.com", @"mail.com", @"yahoo.com.tw"];
    
    GHAssertEqualStrings([MailcheckTester findClosestDomain:@"yahoo.com.tw" domains:defaultDomains], @"yahoo.com.tw", @"yahoo");
    GHAssertEqualStrings([MailcheckTester findClosestDomain:@"hotmail.com" domains:defaultDomains], @"hotmail.com", @"hotmail");
    GHAssertEqualStrings([MailcheckTester findClosestDomain:@"gms.com" domains:defaultDomains], @"gmx.com", @"gmx");
    GHAssertEqualStrings([MailcheckTester findClosestDomain:@"gmsn.com" domains:defaultDomains], @"msn.com", @"msn");
    GHAssertEqualStrings([MailcheckTester findClosestDomain:@"gmaik.com" domains:defaultDomains], @"gmail.com", @"gmail");
}

- (void)testFindClosestTLD {
    NSArray *topLevelDomains = @[@"co.uk", @"com", @"net", @"org", @"info", @"edu", @"gov", @"mil", @"com.tw"];
    GHAssertEqualStrings([MailcheckTester findClosestDomain:@"cmo" domains:topLevelDomains], @"com", @"com");
    GHAssertEqualStrings([MailcheckTester findClosestDomain:@"ogr" domains:topLevelDomains], @"org", @"org");
    GHAssertEqualStrings([MailcheckTester findClosestDomain:@"ifno" domains:topLevelDomains], @"info", @"info");
    GHAssertEqualStrings([MailcheckTester findClosestDomain:@"com.uk" domains:topLevelDomains], @"co.uk", @"co.uk");
}

- (void)testMistypedDomain {
    NSArray *defaultDomains = @[@"yahoo.com", @"google.com", @"hotmail.com", @"gmail.com", @"me.com", @"aol.com", @"mac.com", @"live.com", @"comcast.net", @"googlemail.com", @"msn.com", @"hotmail.co.uk", @"yahoo.co.uk", @"facebook.com", @"verizon.net", @"sbcglobal.net", @"att.net", @"gmx.com", @"mail.com", @"yahoo.com.tw"];
    NSArray *defaultTopLevelDomains = @[@"co.uk", @"com", @"net", @"org", @"info", @"edu", @"gov", @"mil", @"com.tw"];

    GHAssertEqualStrings([Mailcheck suggest:@"test@emaildomain.co" domains:defaultDomains topLevelDomains:defaultTopLevelDomains][@"domain"], @"emaildomain.com", @"email domain");
    GHAssertEqualStrings([Mailcheck suggest:@"test@gmail.con" domains:defaultDomains topLevelDomains:defaultTopLevelDomains][@"domain"], @"gmail.com", @"gmail.con");
    GHAssertEqualStrings([Mailcheck suggest:@"test@gnail.con" domains:defaultDomains topLevelDomains:defaultTopLevelDomains][@"domain"], @"gmail.com", @"gnail");
    GHAssertEqualStrings([Mailcheck suggest:@"test@GNAIL.con" domains:defaultDomains topLevelDomains:defaultTopLevelDomains][@"domain"], @"gmail.com", @"GNAIL");
    GHAssertEqualStrings([Mailcheck suggest:@"test@#gmail.com" domains:defaultDomains topLevelDomains:defaultTopLevelDomains][@"domain"], @"gmail.com", @"#gmail");
    GHAssertEqualStrings([Mailcheck suggest:@"test@comcast.com" domains:defaultDomains topLevelDomains:defaultTopLevelDomains][@"domain"], @"comcast.net", @"comcast");
    GHAssertEqualStrings([Mailcheck suggest:@"test@hotmail.con" domains:defaultDomains topLevelDomains:defaultTopLevelDomains][@"domain"], @"hotmail.com", @"hotmail.con");
    GHAssertEqualStrings([Mailcheck suggest:@"test@hotmail.co" domains:defaultDomains topLevelDomains:defaultTopLevelDomains][@"domain"], @"hotmail.com", @"hotmail.co");
    GHAssertEqualStrings([Mailcheck suggest:@"test@fabecook.com" domains:defaultDomains topLevelDomains:defaultTopLevelDomains][@"domain"], @"facebook.com", @"fabecook.com");
    GHAssertEqualStrings([Mailcheck suggest:@"test@yajoo.com" domains:defaultDomains topLevelDomains:defaultTopLevelDomains][@"domain"], @"yahoo.com", @"yahoo.com");
    GHAssertEqualStrings([Mailcheck suggest:@"test@randomsmallcompany.cmo" domains:defaultDomains topLevelDomains:defaultTopLevelDomains][@"domain"], @"randomsmallcompany.com", @"small company");
    GHAssertNil([Mailcheck suggest:@"test@yahoo.com.tw" domains:defaultDomains topLevelDomains:defaultTopLevelDomains], @"valid");
    GHAssertNil([Mailcheck suggest:@"" domains:defaultDomains topLevelDomains:defaultTopLevelDomains], @"valid");
    GHAssertNil([Mailcheck suggest:@"test@" domains:defaultDomains topLevelDomains:defaultTopLevelDomains], @"valid");
    GHAssertNil([Mailcheck suggest:@"test" domains:defaultDomains topLevelDomains:defaultTopLevelDomains], @"valid");
    
    /* This test is for illustrative purposes as the splitEmail function should return a better
     * representation of the true top-level domain in the case of an email address with subdomains.
     * mailcheck will be unable to return a suggestion in the case of this email address.
     */
    GHAssertNil([Mailcheck suggest:@"test@mail.randomsmallcompany.cmo" domains:defaultDomains topLevelDomains:defaultTopLevelDomains], @"no suggestion");
}

@end
