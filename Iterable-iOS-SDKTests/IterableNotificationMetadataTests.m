//
//  IterableNotificationMetadataTests.m
//  Iterable-iOS-SDK
//
//  Created by Ilya Brin on 6/7/16.
//  Copyright © 2016 Iterable. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "IterableNotificationMetadata.h"

@interface IterableNotificationMetadataTests : XCTestCase

@end

@implementation IterableNotificationMetadataTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testInvalidPayloads {
    NSArray *invalidPayloads = @[
                                 // no "itbl"
                                 @{},
                                 
                                 // no "isGhostPush"
                                 @{
                                     @"itbl": @{
                                             @"campaignId": @0,
                                             @"templateId": @0
                                             }
                                     },
                                 
                                 // no "templateId"
                                 @{
                                     @"itbl": @{
                                             @"campaignId": @0,
                                             @"isGhostPush": @NO
                                             }
                                     },
                                 
                                 // "campaignId" not a number
                                 @{
                                     @"itbl": @{
                                             @"campaignId": @"hello",
                                             @"templateId": @0,
                                             @"isGhostPush": @NO
                                             }
                                     },
                                 
                                 // "templateId" not a number
                                 @{
                                     @"itbl": @{
                                             @"campaignId": @0,
                                             @"templateId": @"world",
                                             @"isGhostPush": @NO
                                             }
                                     },
                                 
                                 // "isGhostPush" not a number (that represents a BOOL; all numbers represent BOOLs though). 0 = NO, everything else = YES
                                 @{
                                     @"itbl": @{
                                             @"campaignId": @0,
                                             @"templateId": @0,
                                             @"isGhostPush": @"lol"
                                             }
                                     }
                                 ];
    for (NSDictionary *payload in invalidPayloads) {
        IterableNotificationMetadata *metadata = [IterableNotificationMetadata metadataFromLaunchOptions:payload];
        XCTAssertNil(metadata);
    }
}

- (void)testValidGhostPayload {
    NSDictionary *payload = @{
      @"itbl": @{
              @"campaignId": @666,
              @"templateId": @777,
              @"isGhostPush": @YES
              }
      };
    IterableNotificationMetadata *metadata = [IterableNotificationMetadata metadataFromLaunchOptions:payload];
    XCTAssertEqual(metadata.campaignId, @666);
    XCTAssertEqual(metadata.templateId, @777);
    XCTAssertTrue(metadata.isGhostPush);
    XCTAssertFalse([metadata isProof]);
    XCTAssertFalse([metadata isTestPush]);
    XCTAssertFalse([metadata isRealCampaignNotification]);
}

- (void)testValidRealPayload {
    NSDictionary *payload = @{
                              @"itbl": @{
                                      @"campaignId": @666,
                                      @"templateId": @777,
                                      @"isGhostPush": @NO
                                      }
                              };
    IterableNotificationMetadata *metadata = [IterableNotificationMetadata metadataFromLaunchOptions:payload];
    XCTAssertEqual(metadata.campaignId, @666);
    XCTAssertEqual(metadata.templateId, @777);
    XCTAssertFalse(metadata.isGhostPush);
    XCTAssertFalse([metadata isProof]);
    XCTAssertFalse([metadata isTestPush]);
    XCTAssertTrue([metadata isRealCampaignNotification]);
}

- (void)testValidProofPayload {
    NSDictionary *payload = @{
                              @"itbl": @{
                                      @"campaignId": @0,
                                      @"templateId": @777,
                                      @"isGhostPush": @NO
                                      }
                              };
    IterableNotificationMetadata *metadata = [IterableNotificationMetadata metadataFromLaunchOptions:payload];
    XCTAssertEqual(metadata.campaignId, @0);
    XCTAssertEqual(metadata.templateId, @777);
    XCTAssertFalse(metadata.isGhostPush);
    XCTAssertTrue([metadata isProof]);
    XCTAssertFalse([metadata isTestPush]);
    XCTAssertFalse([metadata isRealCampaignNotification]);
}

- (void)testValidProofPayloadNoCampaignId {
    NSDictionary *payload = @{
                              @"itbl": @{
                                      @"templateId": @777,
                                      @"isGhostPush": @NO
                                      }
                              };
    IterableNotificationMetadata *metadata = [IterableNotificationMetadata metadataFromLaunchOptions:payload];
    XCTAssertEqual(metadata.campaignId, @0);
    XCTAssertEqual(metadata.templateId, @777);
    XCTAssertFalse(metadata.isGhostPush);
    XCTAssertTrue([metadata isProof]);
    XCTAssertFalse([metadata isTestPush]);
    XCTAssertFalse([metadata isRealCampaignNotification]);
}

- (void)testValidTestPayload {
    NSDictionary *payload = @{
                              @"itbl": @{
                                      @"campaignId": @0,
                                      @"templateId": @0,
                                      @"isGhostPush": @NO
                                      }
                              };
    IterableNotificationMetadata *metadata = [IterableNotificationMetadata metadataFromLaunchOptions:payload];
    XCTAssertEqual(metadata.campaignId, @0);
    XCTAssertEqual(metadata.templateId, @0);
    XCTAssertFalse(metadata.isGhostPush);
    XCTAssertFalse([metadata isProof]);
    XCTAssertTrue([metadata isTestPush]);
    XCTAssertFalse([metadata isRealCampaignNotification]);
}

- (void)testDeserializedFromIterableJson {
    NSString *jsonGhostPush = @"{\"itbl\":{\"campaignId\":666,\"templateId\":777,\"isGhostPush\":true}}";
    id objGhostPush = [NSJSONSerialization
                 JSONObjectWithData:[jsonGhostPush dataUsingEncoding:NSUTF8StringEncoding]
                 options:0
                 error:nil];
    NSDictionary *expectedGhostPush = @{
                               @"itbl": @{
                                       @"campaignId": @666,
                                       @"templateId": @777,
                                       @"isGhostPush": @YES
                                       }
                               };
    XCTAssertEqualObjects(objGhostPush, expectedGhostPush);
    
    NSString *jsonReal = @"{\"itbl\":{\"campaignId\":666,\"templateId\":777,\"isGhostPush\":false}}";
    id objReal = [NSJSONSerialization
                       JSONObjectWithData:[jsonReal dataUsingEncoding:NSUTF8StringEncoding]
                       options:0
                       error:nil];
    NSDictionary *expectedReal = @{
                                        @"itbl": @{
                                                @"campaignId": @666,
                                                @"templateId": @777,
                                                @"isGhostPush": @NO
                                                }
                                        };
    XCTAssertEqualObjects(objReal, expectedReal);
}

@end
