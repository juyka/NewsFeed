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

@interface RequestManager ()

@property (nonatomic) NSString *newsfeedOffset;

@end

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
	VKRequest * getNews = [VKRequest requestWithMethod:@"newsfeed.get" andParameters:@{@"filters": @"post"} andHttpMethod:@"GET"];
	
	[self sendRequest:getNews withBlock:block];
}

- (void)loadMoreNews:(void (^)(NSArray *))block {
	VKRequest * getNews = [VKRequest requestWithMethod:@"newsfeed.get" andParameters:@{
																					   @"filters": @"post",
																					   @"start_from" : self.newsfeedOffset} andHttpMethod:@"GET"];
	
	[self sendRequest:getNews withBlock:block];
}

- (void)sendRequest:(VKRequest *)request withBlock:(void (^)(NSArray *))block{
	
	[request executeWithResultBlock:^(VKResponse * response) {
		
		id nextFrom = response.json[@"response"][@"next_from"];
		if (nextFrom != (id)[NSNull null]) {
			self.newsfeedOffset = nextFrom;
		}
		
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

- (void)changeUserLikes:(BOOL)userLikes itemId:(NSString *)itemID withBlock:(void (^)(BOOL userLikes, NSNumber * likesCount))block {
	NSString *method = [NSString stringWithFormat:@"likes.%@", userLikes ? @"add" : @"delete"];
	VKRequest * request = [VKRequest requestWithMethod:method andParameters:@{@"type": @"post",
																			  @"item_id": itemID} andHttpMethod:@"GET"];
	[request executeWithResultBlock:^(VKResponse * response) {
		
		NSNumber* likesCount = response.json[@"response"][@"likes"];
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
