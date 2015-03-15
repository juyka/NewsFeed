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

@implementation NewsFeedTableViewCell {
	CGFloat _cellWidth;
}

- (void)awakeFromNib {
	[super awakeFromNib];
	self.collectionView.dataSource = self;
	self.collectionView.delegate = self;
	
}

- (void)layoutSubviews {
	[super layoutSubviews];
	[self setItemSize];
}

- (void)configure:(NewsFeedItem *)item {
	
	self.newsFeedItem = item;
	NSURL *url = [NSURL URLWithString:item.sourceImage];
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	UIImage *placeholder = [UIImage imageNamed:@"placeholder"];

	__weak NewsFeedTableViewCell *weakCell = self;
 
	[self.sourceImageView setImageWithURLRequest:request
							   placeholderImage:placeholder
										success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
											
											weakCell.sourceImageView.image = image;
											[weakCell setNeedsLayout];
											
										} failure:nil];
	self.name.text = item.sourceName;
	self.date.text = [NSString stringWithFormat:@"%@", item.date];
	self.text.text = item.text;
	self.likeCount.text = [NSString stringWithFormat:@"%@", item.likeCount];
	self.likeButton.selected = [item.userLikes boolValue];
	[self.collectionView reloadData];
}

- (void)setItemSize {
	
	CGFloat width = self.collectionView.frame.size.width;
	NSInteger cellsInRow = 4;
	_cellWidth = (int)((width - 15) / cellsInRow);
	CGSize cellSize = {_cellWidth, _cellWidth};
	
	CGFloat inset = 5;
	UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
	layout.minimumInteritemSpacing = inset;
	layout.minimumLineSpacing = inset;
	layout.itemSize = cellSize;
	self.collectionViewHeight.constant = (self.newsFeedItem.attachments.count) ? _cellWidth : 0;
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
	NSString * objectID = [NSString stringWithFormat:@"%@", self.newsFeedItem.postID];
	[RequestManager.manager changeUserLikes:button.selected itemId:objectID withBlock:^(BOOL userLikes, NSNumber *likesCount) {
		self.newsFeedItem.userLikes = @(userLikes);
		self.newsFeedItem.likeCount = likesCount;
		[self configure:self.newsFeedItem];
	}];
}



@end
