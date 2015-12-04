//
//  OfflineDataService.h
//  Coursistant Sceleton
//
//  Created by Andrew on 05.03.13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CWLSynthesizeSingleton.h"

@interface OfflineDataManager : NSObject {
        
    NSString *dataFilePath;
    NSMutableDictionary *data;
    BOOL _online;
}

CWL_DECLARE_SINGLETON_FOR_CLASS(OfflineDataManager)

@property (nonatomic, assign, getter=isOnline) BOOL online;

@property (nonatomic, copy) void (^onlineTrackingBlock)(BOOL online);


-(NSString *) userIDFor:(NSString *)providerName;

-(NSArray *) profileFor:(NSString *)providerName;

-(NSArray *) coursewareFor:(NSString *)providerName courseName:(NSString *)courseName;

-(void) updateUserIDFor:(NSString *)providerName userID:(NSString *)newUserID;

-(NSArray *) updateProfileFor:(NSString *)providerName profile:(NSArray *)newProfile;

-(void) updateCoursewareFor:(NSString *)providerName courseName:(NSString *)courseName courseware:(NSArray *)newCourseware;

-(void) startTracking;

+(BOOL) isConnectionNotAvailableError:(NSError *)error;

@end
