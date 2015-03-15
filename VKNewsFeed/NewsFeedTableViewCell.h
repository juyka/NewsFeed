//
//  NewsFeedTableViewCell.h
//  VKNewsFeed
//
//  Created by Настя on 12/03/15.
//  Copyright (c) 2015 Nastya. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NewsFeedItem;
@interface NewsFeedTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *sourceImageView;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *date;
@property (weak, nonatomic) IBOutlet UILabel *text;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UILabel *likeCount;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;


- (void)configure:(NewsFeedItem *)item :(CGFloat)itemSide;

@end
