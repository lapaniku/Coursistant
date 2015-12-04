//
//  CourseraLoginManager.h
//  Coursera Downloader
//
//  Created by Andrew on 21.11.12.
//  Copyright (c) 2012 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ILoginManager.h"
#import "ILoginDelegate.h"
#import "AFHTTPRequestOperation.h"

@interface CourseraCourseLoginManager : NSObject <ILoginManager> {
    
    NSString *username;
    NSString *password;
    AFHTTPRequestOperation *openOperation;
}

@property (nonatomic, assign) id <ILoginDelegate> delegate;

@property (nonatomic) NSString *homeLink;

+(BOOL) isSessionAvailable:(NSString *)classPath;

@end
