//
//  NewsFeedItem.h
//  VKNewsFeed
//
//  Created by Настя on 14/03/15.
//  Copyright (c) 2015 Nastya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface NewsFeedItem : NSManagedObject

@property (nonatomic, retain) NSNumber * date;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSNumber * postID;
@property (nonatomic, retain) NSNumber * ownerID;
@property (nonatomic, retain) NSNumber * likeCount;
@property (nonatomic, retain) NSNumber * userLikes;
@property (nonatomic, retain) NSArray * attachments;
@property (nonatomic, retain) NSString * sourceName;
@property (nonatomic, retain) NSString * sourceImage;
@property (nonatomic, retain) NSString * repostName;
@property (nonatomic, retain) NSString * repostText;

@end
