//
//  BasicJSONManager.h
//  Coursistant
//
//  Created by Andrew on 23.08.13.
//  Copyright (c) 2013 Altasapiens. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IContentManager.h"

@interface BasicJSONManager : NSObject <IContentManager>

@property(nonatomic, assign) id <IContentDelegate> delegate;
@property(nonatomic) id <IContentParser> parser;

@property (nonatomic, copy) void (^onlineDataHandler)(NSString *, NSArray *);

@property (nonatomic, copy) NSArray *(^offlineDataHandler)(NSString *);

@end
