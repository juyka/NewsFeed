//
//  RequestManager.h
//  VKNewsFeed
//
//  Created by Настя on 11/03/15.
//  Copyright (c) 2015 Nastya. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RequestManager : NSObject

+ (instancetype)manager;

- (void)newsFeed:(void(^)(NSArray* entries))block;
- (void)changeUserLikes:(BOOL)userLikes itemId:(NSNumber *)itemID ownerId:(NSNumber *)ownerID withBlock:(void (^)(BOOL userLikes, NSNumber * likesCount))block;

@end
