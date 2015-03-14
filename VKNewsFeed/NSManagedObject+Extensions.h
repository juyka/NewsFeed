//
//  NSManagedObject+Extensions.h
//  VKNewsFeed
//
//  Created by Настя on 12/03/15.
//  Copyright (c) 2015 Nastya. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (Extensions)

+ (NSArray *)findOrCreateArray:(id)entries;

@end
