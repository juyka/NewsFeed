//
//  NSManagedObject+Extensions.m
//  VKNewsFeed
//
//  Created by Настя on 12/03/15.
//  Copyright (c) 2015 Nastya. All rights reserved.
//

#import "NSManagedObject+Extensions.h"
#import <ObjectiveRecord.h>
#import <ObjectiveSugar.h>
#import "NewsFeedItem.h"

@implementation NSManagedObject (Extensions)

+ (NSArray *)findOrCreateArray:(id)entries {
	NSArray *newsFeedItems;
	
	NSArray *items = entries[@"items"];
	NSArray *profiles = entries[@"profiles"];
	NSArray *groups = entries[@"groups"];
	
	NSMutableDictionary *dictionary = NSMutableDictionary.new;
	
	[profiles each:^(id object) {
		NSNumber *profileID = object[@"id"];
		NSString *profileName = [NSString stringWithFormat:@"%@ %@", object[@"first_name"], object[@"last_name"]];
		NSString *profileImage = object[@"photo_50"];
		
		NSDictionary *profileInfo = @{@"sourceName": profileName, @"sourceImage": profileImage};
		
		[dictionary setObject:profileInfo forKey:profileID];
	}];
	
	[groups each:^(id object) {
		NSNumber *profileID = object[@"id"];
		NSString *profileName = object[@"name"];
		NSString *profileImage = object[@"photo_50"];
		
		NSDictionary *profileInfo = @{@"sourceName": profileName, @"sourceImage": profileImage};
		
		[dictionary setObject:profileInfo forKey:profileID];
	}];
	
	newsFeedItems = [items map:^id(id object) {
						NSNumber *itemID = object[@"post_id"];
						NewsFeedItem *item = [NewsFeedItem findOrCreate:@{@"postID": itemID}];
						item.date = object[@"date"];
						item.text = object[@"text"];
						item.likeCount = object[@"likes"][@"count"];
						item.userLikes = object[@"likes"][@"user_likes"];
						NSNumber *sourceID = object[@"source_id"];
						item.sourceName = dictionary[@(abs(sourceID.intValue))][@"sourceName"];
						item.sourceImage = dictionary[@(abs(sourceID.intValue))][@"sourceImage"];
						
						id repost = [object[@"copy_history"] lastObject];
						NSNumber *repostID = repost[@"owner_id"];
						item.repostName = dictionary[@(abs(repostID.intValue))][@"sourceName"];
						NSMutableArray *attachments = NSMutableArray.new;
						[attachments addObjectsFromArray:object[@"attachments"]];
						[attachments addObjectsFromArray:repost[@"attachments"]];
		
		NSMutableArray *filteredAttachments = NSMutableArray.new;// = [attachments filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"type != photo"]];
						[attachments each:^(id attachment) {
							NSString *type = attachment[@"type"];
							if ([type isEqualToString:@"photo"]) {
								NSString *imageURL = attachment[@"photo"][@"photo_604"];
								[filteredAttachments addObject:imageURL];
							}
						}];
		item.attachments = filteredAttachments;
						return item;

					}];
	
	return newsFeedItems;
}

@end
