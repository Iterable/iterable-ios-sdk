//
//  IterableConfig.m
//  Iterable-iOS-SDK
//
//  Created by Victor Babenko on 6/18/18.
//  Copyright © 2018 Iterable. All rights reserved.
//

#import "IterableConfig.h"
#import "IterableAction.h"
#import "IterableActionContext.h"

@implementation IterableConfig

- (instancetype)init {
    self = [super init];
    if (self) {
        _pushPlatform = AUTO;
    }
    return self;
}

@end
