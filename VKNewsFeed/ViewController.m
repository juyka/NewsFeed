//
//  ViewController.m
//  VKNewsFeed
//
//  Created by Настя on 11/03/15.
//  Copyright (c) 2015 Nastya. All rights reserved.
//

#import "ViewController.h"
#import "RequestManager.h"
#import "NewsFeedItem.h"
#import "NewsFeedTableViewCell.h"
#import <VKSdk.h>


@interface ViewController ()<VKSdkDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSArray *dataSource;
@end
//437437

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.tableView.rowHeight = UITableViewAutomaticDimension;
	self.tableView.estimatedRowHeight = 100.0f;
	self.tableView.tableFooterView = UIView.new;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	NSString *clientID = @"4823123";
	[VKSdk initializeWithDelegate:self andAppId:clientID];
	if ([VKSdk wakeUpSession]){
		[RequestManager.manager newsFeed:^(NSArray *entries) {
			self.dataSource = entries;
			[self.tableView reloadData];
		}];
	} else {
		NSArray *permissions = @[VK_PER_WALL,VK_PER_FRIENDS,VK_PER_PHOTOS];
		[VKSdk authorize:permissions revokeAccess:YES];
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	NewsFeedItem *item = self.dataSource[indexPath.row];
	NSString *cellID = @"Cell";
	NewsFeedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
	
	[cell configure:item];

	return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	return self.dataSource.count;
}

#pragma mark VKSdkDelegate methods ---------------------------

- (void)vkSdkNeedCaptchaEnter:(VKError *)captchaError {
	NSLog(@"%@", captchaError);
}

- (void)vkSdkUserDeniedAccess:(VKError *)authorizationError {
	NSLog(@"%@", authorizationError);
}

- (void)vkSdkReceivedNewToken:(VKAccessToken *)newToken {
	NSLog(@"%@", newToken);
}

- (void)vkSdkShouldPresentViewController:(UIViewController *)controller {
	[self presentViewController:controller animated:YES completion:nil];
}

- (void)vkSdkTokenHasExpired:(VKAccessToken *)expiredToken {
	NSLog(@"%@", expiredToken);
}

@end
