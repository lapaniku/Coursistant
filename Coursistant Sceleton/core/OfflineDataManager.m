//
//  OfflineDataService.m
//  Coursistant Sceleton
//
//  Created by Andrew on 05.03.13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import "OfflineDataManager.h"
#import "CWLSynthesizeSingleton.h"
#import "NSFileManager+DirectoryLocations.h"
#import "Reachability.h"

@implementation OfflineDataManager

CWL_SYNTHESIZE_SINGLETON_FOR_CLASS(OfflineDataManager);

-(id) init {
        
    self = [super init];
    dataFilePath = [[[NSFileManager defaultManager] applicationSupportDirectory] stringByAppendingPathComponent:@"userdata"];
    NSData *dataFileContents = [[NSData alloc] initWithContentsOfFile:dataFilePath];
    // todo: make all dictionaries and arrays mutable
    if(dataFileContents != nil) {
        
        data = [NSKeyedUnarchiver unarchiveObjectWithData:dataFileContents ];
        
    } else {
        data = [[NSMutableDictionary alloc] init];
    }
            
    return self;
}

-(void) startTracking {
    Reachability * reach = [Reachability reachabilityWithHostname:@"google.com"];
    _online = [reach isReachable];
    [reach startNotifier];
    
    reach.reachableBlock = ^(Reachability * reachability) {
        if(self.onlineTrackingBlock != nil) {
            self.onlineTrackingBlock(YES);
        }
    };
    
    reach.unreachableBlock = ^(Reachability * reachability) {
        _online = NO;
        if(self.onlineTrackingBlock != nil) {
            self.onlineTrackingBlock(NO);
        }
    };
}


-(NSString *) userIDFor:(NSString *)providerName {
    NSDictionary *userIDMap = [data valueForKey:@"userIDMap"];
    return [userIDMap valueForKey:providerName];
}

-(NSArray *) profileFor:(NSString *)providerName {
    NSDictionary *profileMap = [data valueForKey:@"profileMap"];
    return [profileMap valueForKey:providerName];
}

-(NSArray *) coursewareFor:(NSString *)providerName courseName:(NSString *)courseName {
    NSDictionary *coursewareMap = [data valueForKey:@"coursewareMap"];
    return [coursewareMap valueForKey:[OfflineDataManager coursewarePath:providerName courseName:courseName]];
}

-(void) updateUserIDFor:(NSString *)providerName userID:(NSString *)newUserID {
    NSDictionary *userIDMap = [data valueForKey:@"userIDMap"];
    if(userIDMap == nil) {
        userIDMap = [[NSMutableDictionary alloc] initWithObjectsAndKeys:newUserID, providerName, nil];
        if(![data isKindOfClass:[NSMutableDictionary class]]) {
            data = [data mutableCopy];
        }
        [data setValue:userIDMap forKey:@"userIDMap"];
        [self flush];
    } else {
        if(![userIDMap respondsToSelector:@selector(setValue:forKey:)]) {
            userIDMap = [userIDMap mutableCopy];
            [data setValue:userIDMap forKey:@"userIDMap"];
        }
        NSString *currentUserID = [userIDMap valueForKey:providerName];
        if((currentUserID == nil) || ![currentUserID isEqualToString:newUserID]) {
            [userIDMap setValue:newUserID forKey:providerName];
            [self flush];
        }
    }
}

-(NSArray *) updateProfileFor:(NSString *)providerName profile:(NSArray *)newProfile {
    
    return [self updateOfflineDataWithArray:@"profileMap" key:providerName array:newProfile];
}

-(void) updateCoursewareFor:(NSString *)providerName courseName:(NSString *)courseName courseware:(NSArray *)newCourseware {
    
    NSString *key = [OfflineDataManager coursewarePath:providerName courseName:courseName];
    [self updateOfflineDataWithArray:@"coursewareMap" key:key array:newCourseware];
}

-(NSArray *) updateOfflineDataWithArray:(NSString *)mapTitle key:(NSString *)key array:(NSArray *)newArray{
    
    NSString *newKey = key;
    NSDictionary *map = [data valueForKey:mapTitle];
    if(map == nil) {
        map = [[NSMutableDictionary alloc] initWithObjectsAndKeys:newArray, newKey, nil];
        if(![data isKindOfClass:[NSMutableDictionary class]]) {
            data = [data mutableCopy];
        }
        [data setValue:map forKey:mapTitle];
        [self flush];
    } else {
        if(![map respondsToSelector:@selector(setValue:forKey:)]) {
            map = [map mutableCopy];
            [data setValue:map forKey:mapTitle];
        }
        NSArray *currentArray = [map objectForKey:key];
        if((currentArray == nil) || (((newArray != nil) && (newArray.count > 0)) && ![currentArray isEqualToArray:newArray])) {
            [map setValue:newArray forKey:newKey];
            [self flush];
            if([currentArray count] < [newArray count]) {
                NSMutableArray *newItems = [newArray mutableCopy];
                [newItems removeObjectsInArray:currentArray];
                return newItems;
            }
        }
    }
    return nil;
}

-(void) flush {
//    NSData *dataFileContents = [NSJSONSerialization dataWithJSONObject:data options:0 error:nil];
    NSData *dataFileContents = [NSKeyedArchiver archivedDataWithRootObject:data];
    
    [dataFileContents writeToFile:dataFilePath atomically:YES];
}

+(NSString *) coursewarePath:(NSString *)providerName courseName:(NSString *)courseName {
    return [providerName stringByAppendingPathComponent:courseName];
}

+(BOOL) isConnectionNotAvailableError:(NSError *)error {
        
    return error.code == -1009;
}

-(void) setOnline:(BOOL)newOnline {
    if(newOnline) {
        _online = newOnline && [Reachability reachabilityWithHostname:@"google.com"].isReachable;
    } else {
        _online = false;
    }
    self.onlineTrackingBlock(_online);
}

-(BOOL) isOnline {
    return _online;
}

@end
