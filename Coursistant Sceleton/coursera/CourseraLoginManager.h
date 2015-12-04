//
//  CourseraLoginManager.h
//  Coursistant Sceleton
//
//  Created by Andrew on 21.02.13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ILoginManager.h"
#import "ILoginDelegate.h"
#import "GlobalConst.h"


@interface CourseraLoginManager : NSObject <ILoginManager>

@property(nonatomic, assign) id <ILoginDelegate> delegate;

@end
