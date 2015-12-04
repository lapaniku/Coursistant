//
//  CourseraCoursewareManager.h
//  Coursistant Sceleton
//
//  Created by Andrew on 22.02.13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IContentManager.h"
#import "ILoginDelegate.h"
#import "CourseraCourseLoginManager.h"

@interface CourseraCoursewareManager : NSObject <IContentManager, ILoginDelegate> {
    
    NSString *courseTitle;
}

@property(nonatomic, assign) id <IContentDelegate> delegate;

@property(nonatomic) id <IContentParser> parser;

@property(nonatomic) NSURL *courseURL;

@property(nonatomic) NSString *username;

@property(nonatomic) NSString *password;

@end
