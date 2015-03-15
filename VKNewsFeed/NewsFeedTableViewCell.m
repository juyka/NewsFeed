//
//  NewsFeedTableViewCell.m
//  VKNewsFeed
//
//  Created by Настя on 12/03/15.
//  Copyright (c) 2015 Nastya. All rights reserved.
//

#import "NewsFeedTableViewCell.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import "NewsFeedItem.h"
#import "NewsFeedCollectionViewCell.h"
#import "AndMoreCollectionViewCell.h"
#import "RequestManager.h"


@interface NewsFeedTableViewCell ()<UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic) NewsFeedItem *newsFeedItem;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionViewHeight;

@end

@implementation NewsFeedTableViewCell

- (void)awakeFromNib {
	[super awakeFromNib];
	self.collectionView.dataSource = self;
	self.collectionView.delegate = self;
}

- (void)configure:(NewsFeedItem *)item :(CGFloat)itemSide {
	
	self.newsFeedItem = item;
	NSURL *url = [NSURL URLWithString:item.sourceImage];
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	UIImage *placeholder = [UIImage imageNamed:@"placeholder"];
	
	__weak NewsFeedTableViewCell *weakCell = self;
 
	[self.sourceImageView setImageWithURLRequest:request
								placeholderImage:placeholder
										 success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
											 
											 weakCell.sourceImageView.image = image;
										 } failure:nil];
	self.name.text = item.sourceName;
	self.date.text = [NSString stringWithFormat:@"%@", item.date];
	self.text.text = item.text;
	self.likeCount.text = [NSString stringWithFormat:@"%@", item.likeCount];
	self.likeButton.selected = [item.userLikes boolValue];
	
	UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
	layout.itemSize = CGSizeMake(itemSide, itemSide);
	layout.minimumInteritemSpacing = 8;
	self.collectionViewHeight.constant = self.newsFeedItem.attachments.count ? itemSide : 0;
	[self.collectionView reloadData];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	BOOL isAndMoreCell = (indexPath.row == 3 && self.newsFeedItem.attachments.count > 4);
	
	UICollectionViewCell *cell;
	
	if (isAndMoreCell) {
		AndMoreCollectionViewCell *andMoreCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AndMoreCell" forIndexPath:indexPath];
		andMoreCell.label.text = [NSString stringWithFormat:@"+ %ld", self.newsFeedItem.attachments.count - 3];
		cell = andMoreCell;
	} else {
		NewsFeedCollectionViewCell *newsFeedCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"NewsFeedCell" forIndexPath:indexPath];
		
		NSString *imageURL = self.newsFeedItem.attachments[indexPath.row];
		NSURL *url = [NSURL URLWithString:imageURL];
		NSURLRequest *request = [NSURLRequest requestWithURL:url];
		UIImage *placeholder = [UIImage imageNamed:@"placeholder"];
		newsFeedCell.imageView.image = nil;
		[newsFeedCell.imageView setImageWithURLRequest:request
									  placeholderImage:placeholder
											   success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
												   
												   newsFeedCell.imageView.image = image;
												   [newsFeedCell setNeedsLayout];
												   
											   } failure:nil];
		cell = newsFeedCell;
	}
	
	return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	
	return MIN(self.newsFeedItem.attachments.count, 4);
}

- (IBAction)likeIt:(id)sender {
	UIButton *button = sender;
	button.selected = !button.selected;
	
	[RequestManager.manager changeUserLikes:button.selected itemId:self.newsFeedItem.postID ownerId:self.newsFeedItem.ownerID withBlock:^(BOOL userLikes, NSNumber *likesCount) {
		self.newsFeedItem.userLikes = @(userLikes);
		self.newsFeedItem.likeCount = likesCount;
		self.likeCount.text = [NSString stringWithFormat:@"%@", likesCount];
		self.likeButton.selected = userLikes;

	}];
}

@end
