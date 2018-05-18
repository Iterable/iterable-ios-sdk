//
//  IterableActionRunnerTests.m
//  Iterable-iOS-SDKTests
//
//  Created by Victor Babenko on 5/14/18.
//  Copyright © 2018 Iterable. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "IterableAPI.h"
#import "IterableActionRunner.h"

@interface IterableActionRunnerTests : XCTestCase

@end

@implementation IterableActionRunnerTests

- (void)setUp {
    [super setUp];
    [IterableAPI sharedInstanceWithApiKey:@"" andEmail:@"" launchOptions:nil];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testUrlOpenAction {
    id urlDelegateMock = OCMProtocolMock(@protocol(IterableURLDelegate));
    id applicationMock = OCMPartialMock([UIApplication sharedApplication]);
    IterableAPI.sharedInstance.urlDelegate = urlDelegateMock;
    IterableAction *action = [IterableAction actionFromDictionary:@{ @"type": @"openUrl", @"data": @"https://example.com" }];
    [IterableActionRunner executeAction:action];
    
    OCMVerify([urlDelegateMock handleIterableURL:[OCMArg isEqual:[NSURL URLWithString:@"https://example.com"]] fromAction:[OCMArg isEqual:action]]);
    OCMVerify([applicationMock openURL:[OCMArg any] options:[OCMArg any] completionHandler:[OCMArg any]]);
    [applicationMock stopMocking];
}

- (void)testUrlHandlingOverride {
    id urlDelegateMock = OCMProtocolMock(@protocol(IterableURLDelegate));
    id applicationMock = OCMPartialMock([UIApplication sharedApplication]);
    OCMReject([applicationMock openURL:[OCMArg any] options:[OCMArg any] completionHandler:[OCMArg any]]);
    OCMStub([urlDelegateMock handleIterableURL:[OCMArg any] fromAction:[OCMArg any]]).andReturn(YES);
    IterableAPI.sharedInstance.urlDelegate = urlDelegateMock;
    IterableAction *action = [IterableAction actionFromDictionary:@{ @"type": @"openUrl", @"data": @"https://example.com" }];
    [IterableActionRunner executeAction:action];
    
    [applicationMock stopMocking];
}

- (void)testCustomAction {
    id customActionDelegateMock = OCMProtocolMock(@protocol(IterableCustomActionDelegate));
    IterableAPI.sharedInstance.customActionDelegate = customActionDelegateMock;
    IterableAction *action = [IterableAction actionFromDictionary:@{ @"type": @"customActionName" }];
    [IterableActionRunner executeAction:action];
    
    OCMVerify([customActionDelegateMock handleIterableCustomAction:[OCMArg checkWithBlock:^BOOL(IterableAction *action) {
        XCTAssertEqualObjects(action.type, @"customActionName");
        return YES;
    }]]);
}

@end
