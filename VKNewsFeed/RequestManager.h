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
- (void)loadMoreNews:(void(^)(NSArray* entries))block;

@end
