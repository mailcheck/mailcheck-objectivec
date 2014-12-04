//
//  TestMailcheck.m
//  Frost
//
//  Created by David Kasper on 1/3/13.
//  Copyright (c) 2013 Mixbook. All rights reserved.
//  Licensed under the MIT License.
//

#import <XCTest/XCTest.h>
#import "Mailcheck.h"

@interface MailcheckTester : Mailcheck
+(NSString *)findClosestDomain:(NSString *)domain domains:(NSArray *)domains;
+(NSDictionary *)splitEmail:(NSString *)email;
@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"
@implementation MailcheckTester

@end
#pragma clang diagnostic pop

@interface TestMailcheck : XCTestCase { }
@end

@implementation TestMailcheck

- (void)testValid {
    NSDictionary *result = [Mailcheck suggest:@"david@hotmail.com"];
    XCTAssertNil(result, @"nil for valid domain");
}

- (void)testSplitEmail {
    XCTAssertEqualObjects([MailcheckTester splitEmail:@"test@example.com"], (@{@"address" : @"test", @"domain": @"example.com", @"topLevelDomain": @"com"}), @"basic");
    XCTAssertEqualObjects([MailcheckTester splitEmail:@"test@example.co.uk"], (@{@"address" : @"test", @"domain": @"example.co.uk", @"topLevelDomain": @"co.uk"}), @"co.uk");
    XCTAssertEqualObjects([MailcheckTester splitEmail:@"test@mail.randomsmallcompany.co.uk"], (@{@"address" : @"test", @"domain": @"mail.randomsmallcompany.co.uk", @"topLevelDomain": @"randomsmallcompany.co.uk"}), @"randomsmallcompany");
    XCTAssertEqualObjects([MailcheckTester splitEmail:@"\"foo@bar\"@example.com"], (@{@"address" : @"\"foo@bar\"", @"domain": @"example.com", @"topLevelDomain": @"com"}), @"foobar");
    XCTAssertEqualObjects([MailcheckTester splitEmail:@"containsnumbers1234567890@example.com"], (@{@"address" : @"containsnumbers1234567890", @"domain": @"example.com", @"topLevelDomain": @"com"}), @"basic");
    XCTAssertEqualObjects([MailcheckTester splitEmail:@"contains+symbol@example.com"], (@{@"address" : @"contains+symbol", @"domain": @"example.com", @"topLevelDomain": @"com"}), @"+ symbol");
    XCTAssertEqualObjects([MailcheckTester splitEmail:@"contains-symbol@example.com"], (@{@"address" : @"contains-symbol", @"domain": @"example.com", @"topLevelDomain": @"com"}), @"- symbol");
    XCTAssertEqualObjects([MailcheckTester splitEmail:@"contains.symbol@example.com"], (@{@"address" : @"contains.symbol", @"domain": @"example.com", @"topLevelDomain": @"com"}), @". symbol");
    XCTAssertEqualObjects([MailcheckTester splitEmail:@"\"contains.and\\ symbols\"@example.com"], (@{@"address" : @"\"contains.and\\ symbols\"", @"domain": @"example.com", @"topLevelDomain": @"com"}), @". and \\ symbols");
    XCTAssertEqualObjects([MailcheckTester splitEmail:@"\"contains.and.@.symbols.com\"@example.com"], (@{@"address" : @"\"contains.and.@.symbols.com\"", @"domain": @"example.com", @"topLevelDomain": @"com"}), @"@ and \\ symbols");
    XCTAssertEqualObjects([MailcheckTester splitEmail:@"\"()<>[]:;@,\\\"!#$%&\'*+-/=?^_`{}|^_`{}|~.a\"@allthesymbols.com"], (@{@"address" : @"\"()<>[]:;@,\\\"!#$%&\'*+-/=?^_`{}|^_`{}|~.a\"", @"domain": @"allthesymbols.com", @"topLevelDomain": @"com"}), @"all the symbols");
    XCTAssertEqualObjects([MailcheckTester splitEmail:@"postbox@com"], (@{@"address" : @"postbox", @"domain": @"com", @"topLevelDomain": @"com"}), @"basic");
}

- (void)testInvalidEmail {
    XCTAssertNil([Mailcheck suggest:@"david@"], @"no domain");
    XCTAssertNil([Mailcheck suggest:@"@hotmail.com"], @"no address");
    XCTAssertNil([Mailcheck suggest:@"example.com"], @"domain only");
    XCTAssertNil([Mailcheck suggest:@"abc.example.com"], @"subdomain only");
    XCTAssertNil([MailcheckTester splitEmail:@"david@"], @"no domain");
    XCTAssertNil([MailcheckTester splitEmail:@"@hotmail.com"], @"no address");
    XCTAssertNil([MailcheckTester splitEmail:@"example.com"], @"domain only");
    XCTAssertNil([MailcheckTester splitEmail:@"abc.example.com"], @"subdomain only");
}

- (void)testFindClosestDomain {
    NSArray *defaultDomains = @[@"yahoo.com", @"google.com", @"hotmail.com", @"gmail.com", @"me.com", @"aol.com", @"mac.com", @"live.com", @"comcast.net", @"googlemail.com", @"msn.com", @"hotmail.co.uk", @"yahoo.co.uk", @"facebook.com", @"verizon.net", @"sbcglobal.net", @"att.net", @"gmx.com", @"mail.com", @"yahoo.com.tw"];
    
    XCTAssertEqualObjects([MailcheckTester findClosestDomain:@"yahoo.com.tw" domains:defaultDomains], @"yahoo.com.tw", @"yahoo");
    XCTAssertEqualObjects([MailcheckTester findClosestDomain:@"hotmail.com" domains:defaultDomains], @"hotmail.com", @"hotmail");
    XCTAssertEqualObjects([MailcheckTester findClosestDomain:@"gms.com" domains:defaultDomains], @"gmx.com", @"gmx");
    XCTAssertEqualObjects([MailcheckTester findClosestDomain:@"gmsn.com" domains:defaultDomains], @"msn.com", @"msn");
    XCTAssertEqualObjects([MailcheckTester findClosestDomain:@"gmaik.com" domains:defaultDomains], @"gmail.com", @"gmail");
}

- (void)testFindClosestTLD {
    NSArray *topLevelDomains = @[@"co.uk", @"com", @"net", @"org", @"info", @"edu", @"gov", @"mil", @"com.tw"];
    XCTAssertEqualObjects([MailcheckTester findClosestDomain:@"cmo" domains:topLevelDomains], @"com", @"com");
    XCTAssertEqualObjects([MailcheckTester findClosestDomain:@"ogr" domains:topLevelDomains], @"org", @"org");
    XCTAssertEqualObjects([MailcheckTester findClosestDomain:@"ifno" domains:topLevelDomains], @"info", @"info");
    XCTAssertEqualObjects([MailcheckTester findClosestDomain:@"com.uk" domains:topLevelDomains], @"co.uk", @"co.uk");
}

- (void)testMistypedDomain {
    NSArray *defaultDomains = @[@"yahoo.com", @"google.com", @"hotmail.com", @"gmail.com", @"me.com", @"aol.com", @"mac.com", @"live.com", @"comcast.net", @"googlemail.com", @"msn.com", @"hotmail.co.uk", @"yahoo.co.uk", @"facebook.com", @"verizon.net", @"sbcglobal.net", @"att.net", @"gmx.com", @"mail.com", @"yahoo.com.tw"];
    NSArray *defaultTopLevelDomains = @[@"co.uk", @"com", @"net", @"org", @"info", @"edu", @"gov", @"mil", @"com.tw"];
    
    XCTAssertEqualObjects([Mailcheck suggest:@"test@emaildomain.co" domains:defaultDomains topLevelDomains:defaultTopLevelDomains][@"domain"], @"emaildomain.com", @"email domain");
    XCTAssertEqualObjects([Mailcheck suggest:@"test@gmail.con" domains:defaultDomains topLevelDomains:defaultTopLevelDomains][@"domain"], @"gmail.com", @"gmail.con");
    XCTAssertEqualObjects([Mailcheck suggest:@"test@gnail.con" domains:defaultDomains topLevelDomains:defaultTopLevelDomains][@"domain"], @"gmail.com", @"gnail");
    XCTAssertEqualObjects([Mailcheck suggest:@"test@GNAIL.con" domains:defaultDomains topLevelDomains:defaultTopLevelDomains][@"domain"], @"gmail.com", @"GNAIL");
    XCTAssertEqualObjects([Mailcheck suggest:@"test@#gmail.com" domains:defaultDomains topLevelDomains:defaultTopLevelDomains][@"domain"], @"gmail.com", @"#gmail");
    XCTAssertEqualObjects([Mailcheck suggest:@"test@comcast.com" domains:defaultDomains topLevelDomains:defaultTopLevelDomains][@"domain"], @"comcast.net", @"comcast");
    XCTAssertEqualObjects([Mailcheck suggest:@"test@hotmail.con" domains:defaultDomains topLevelDomains:defaultTopLevelDomains][@"domain"], @"hotmail.com", @"hotmail.con");
    XCTAssertEqualObjects([Mailcheck suggest:@"test@hotmail.co" domains:defaultDomains topLevelDomains:defaultTopLevelDomains][@"domain"], @"hotmail.com", @"hotmail.co");
    XCTAssertEqualObjects([Mailcheck suggest:@"test@fabecook.com" domains:defaultDomains topLevelDomains:defaultTopLevelDomains][@"domain"], @"facebook.com", @"fabecook.com");
    XCTAssertEqualObjects([Mailcheck suggest:@"test@yajoo.com" domains:defaultDomains topLevelDomains:defaultTopLevelDomains][@"domain"], @"yahoo.com", @"yahoo.com");
    XCTAssertEqualObjects([Mailcheck suggest:@"test@randomsmallcompany.cmo" domains:defaultDomains topLevelDomains:defaultTopLevelDomains][@"domain"], @"randomsmallcompany.com", @"small company");
    XCTAssertNil([Mailcheck suggest:@"test@yahoo.com.tw" domains:defaultDomains topLevelDomains:defaultTopLevelDomains], @"valid");
    XCTAssertNil([Mailcheck suggest:@"" domains:defaultDomains topLevelDomains:defaultTopLevelDomains], @"valid");
    XCTAssertNil([Mailcheck suggest:@"test@" domains:defaultDomains topLevelDomains:defaultTopLevelDomains], @"valid");
    XCTAssertNil([Mailcheck suggest:@"test" domains:defaultDomains topLevelDomains:defaultTopLevelDomains], @"valid");
    
    /* This test is for illustrative purposes as the splitEmail function should return a better
     * representation of the true top-level domain in the case of an email address with subdomains.
     * mailcheck will be unable to return a suggestion in the case of this email address.
     */
    XCTAssertNil([Mailcheck suggest:@"test@mail.randomsmallcompany.cmo" domains:defaultDomains topLevelDomains:defaultTopLevelDomains], @"no suggestion");
}

@end
