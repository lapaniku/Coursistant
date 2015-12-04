//
//  CourseraPlayerManager.h
//  Coursistant
//
//  Created by Andrei Lapanik on 22.11.13.
//  Copyright (c) 2013 Altasapiens. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IContentDelegate.h"
#import "IContentParser.h"
#import "IContentManager.h"

@interface CourseraPlayerManager : NSObject <IContentManager> {
}

@property(nonatomic, strong) id <IContentDelegate> delegate;

@property(nonatomic, strong) id <IContentParser> parser;

@end
