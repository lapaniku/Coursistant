//
//  BasicCoursewareManager.h
//  Coursistant Sceleton
//
//  Created by Andrew on 14.01.13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IContentManager.h"

@interface BasicContentManager : NSObject <IContentManager>

@property(nonatomic, assign) id <IContentDelegate> delegate;
@property(nonatomic) id <IContentParser> parser;

@property (nonatomic, copy) void (^onlineDataHandler)(NSString *, NSArray *);

@property (nonatomic, copy) NSArray *(^offlineDataHandler)(NSString *);

@end
