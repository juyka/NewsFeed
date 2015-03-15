//
//  RequestManager.m
//  VKNewsFeed
//
//  Created by Настя on 11/03/15.
//  Copyright (c) 2015 Nastya. All rights reserved.
//

#import "RequestManager.h"
#import <VKSdk.h>
#import "NSManagedObject+Extensions.h"
#import "NewsFeedItem.h"


@implementation RequestManager

+ (instancetype)manager {
	
	static RequestManager *manager;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		
		manager = [[self alloc] init];
	});
	
	return manager;
}

- (void)newsFeed:(void (^)(NSArray *))block {
	VKRequest *getNews = [VKRequest requestWithMethod:@"newsfeed.get" andParameters:@{@"filters": @"post"} andHttpMethod:@"GET"];
	
	[getNews executeWithResultBlock:^(VKResponse * response) {
		
		NSArray *newsFeedItems = [NewsFeedItem findOrCreateArray:response.json];
		
		block(newsFeedItems);
	} errorBlock:^(NSError * error) {
		if (error.code != VK_API_ERROR) {
			[error.vkError.request repeat];
		}
		else {
			NSLog(@"VK error: %@", error);
		}
	}];
}

- (void)changeUserLikes:(BOOL)userLikes itemId:(NSNumber *)itemID ownerId:(NSNumber *)ownerID withBlock:(void (^)(BOOL userLikes, NSNumber * likesCount))block {
	NSString *objectID = [NSString stringWithFormat:@"%@", itemID];
	NSString *sourceID = [NSString stringWithFormat:@"%@", ownerID];
	NSString *method = [NSString stringWithFormat:@"likes.%@", userLikes ? @"add" : @"delete"];
	VKRequest *request = [VKRequest requestWithMethod:method andParameters:@{@"type": @"post",
																			  @"item_id": objectID,
																			  @"owner_id": sourceID} andHttpMethod:@"GET"];
	[request executeWithResultBlock:^(VKResponse * response) {
		
		NSNumber *likesCount = response.json[@"likes"];
		block(userLikes, likesCount);
	} errorBlock:^(NSError * error) {
		if (error.code != VK_API_ERROR) {
			[error.vkError.request repeat];
		}
		else {
			NSLog(@"VK error: %@", error);
		}
	}];

}

@end
