//
//  CSTUnitedProfile.h
//  Coursistant Sceleton
//
//  Created by Администратор on 29.3.13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IProfileDelegate.h"
#import "CWLSynthesizeSingleton.h"

@protocol UnitedProfileDelegate <NSObject>

@required
- (void) unitedProfileExtracted:(NSArray *)courseList newCourses:(NSArray *)newCourses errorMessage:(NSString *)errorMessage;

@end

@interface CSTUnitedProfile : NSObject <IProfileDelegate>

CWL_DECLARE_SINGLETON_FOR_CLASS(CSTUnitedProfile)

@property (nonatomic) NSUInteger expectedRequestCount;

@property (strong, nonatomic) NSString *errorMessage;

@property NSString *httpResponseCode;

@property NSMutableArray *courses;

@property NSMutableArray *addedCourses;

@property(nonatomic,assign)id <UnitedProfileDelegate> delegate;

-(void) renew:(id<UnitedProfileDelegate>) aDelegate;

-(NSString *) coursesDescription;

@end
