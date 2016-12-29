//
//  IterableNotification.m
//  Iterable-iOS-SDK
//
//  Created by Ilya Brin on 6/7/16.
//  Copyright © 2016 Iterable. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "IterableNotificationMetadata.h"

@implementation IterableNotificationMetadata

//////////////////////////
/// @name String constants
//////////////////////////

static NSString *const MetadataField = @"itbl";
static NSString *const CampaignIdField = @"campaignId";
static NSString *const TemplateIdField = @"templateId";
static NSString *const MessageIdField = @"messageId";
static NSString *const IsGhostPushField = @"isGhostPush";

//////////////////////////
/// @name Internal methods
//////////////////////////

/**
 @method
 
 @abstract          Checks if a push notification originated from Iterable
 
 @param userInfo    The notification payload

 @return            `YES` if the notification is from Iterable; `NO` otherwise
 */
+ (BOOL)isIterableNotification:(NSDictionary *)userInfo
{
    if (userInfo && userInfo[MetadataField]) {
        id pushData = userInfo[MetadataField];
        return [pushData isKindOfClass:[NSDictionary class]]
            && (pushData[CampaignIdField] ? [pushData[CampaignIdField] isKindOfClass:[NSNumber class]] : YES) // campaignId doesn't have to be there (because of proofs)
            && [pushData[TemplateIdField] isKindOfClass:[NSNumber class]]
            && [pushData[MessageIdField] isKindOfClass:[NSString class]]
            && [pushData[IsGhostPushField] isKindOfClass:[NSNumber class]];
    } else {
        return NO;
    }
}

/**
 @method
 
 @abstract          Creates an `IterableNotificationMetadata` from a push payload
 
 @param userInfo    The notification payload
 
 @return            An instance of `IterableNotificationMetadata` with the specified properties
 
 @warning           This method assumes that `userInfo` is an Iterable notification (via `isIterableNotification` check beforehand)
 */
- (instancetype)initFromLaunchOptions:(NSDictionary *)userInfo
{
    if (self = [super init]) {
        NSDictionary *pushData = userInfo[MetadataField];
        _campaignId = pushData[CampaignIdField] ? pushData[CampaignIdField] : @0;
        _templateId = pushData[TemplateIdField];
        _messageId = pushData[MessageIdField];
        _isGhostPush = [pushData[IsGhostPushField] boolValue];
    }
    return self;
}

/**
 @method
 
 @abstract          Creates an `IterableNotificationMetadata` from a InApp payload
 
 @param campaignId  The notification campaignId
 @param templateId  The notification templateId
 @param messageId   The notification messageId
 
 @return            An instance of `IterableNotificationMetadata` with the specified properties
 
 @warning           This method assumes that `userInfo` is an Iterable notification (via `isIterableNotification` check beforehand)
 */
- (instancetype)initFromInAppOptions:(NSNumber *)campaignId templateId:(NSNumber *)templateId messageId:(NSString *)messageId
{
    if (self = [super init]) {
        _campaignId = campaignId;
        _templateId = templateId;
        _messageId = messageId;
    }
    return self;
}

////////////////////////
/// @name Implementation
////////////////////////

// documented in IterableNotification.h
+ (instancetype)metadataFromLaunchOptions:(NSDictionary *)userInfo
{
    if ([IterableNotificationMetadata isIterableNotification:userInfo]) {
        return [[IterableNotificationMetadata alloc] initFromLaunchOptions:userInfo];
    } else {
        return nil;
    }
}

// documented in IterableNotification.h
+ (instancetype)metadataFromInAppOptions:(NSNumber *)campaignId templateId:(NSNumber *)templateId messageId:(NSString *)messageId
{
    if (campaignId != nil && templateId != nil) {
        return [[IterableNotificationMetadata alloc] initFromInAppOptions:campaignId templateId:templateId messageId:messageId];
    } else {
        return nil;
    }
    
}

// documented in IterableNotification.h
- (BOOL)isProof {
    return _campaignId.integerValue == 0 && _templateId.integerValue != 0;
}

// documented in IterableNotification.h
- (BOOL)isTestPush {
    return _campaignId.integerValue == 0 && _templateId.integerValue == 0;
}

// documented in IterableNotification.h
- (BOOL)isRealCampaignNotification {
    return !(_isGhostPush || [self isProof] || [self isTestPush]);
}

@end
