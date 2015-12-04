//
//  CourseraProfileManager.h
//  Coursistant Sceleton
//
//  Created by Andrew on 21.02.13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IProfileManager.h"
#import "IProfileDelegate.h"
#import "OperationService.h"



@interface CourseraProfileManager : NSObject <IProfileManager>

@property(nonatomic, assign) id <IProfileDelegate> delegate;

@end
