//
//  ProgressDataManager.m
//  Coursistant Sceleton
//
//  Created by Andrew on 18.06.13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import "ProgressDataManager.h"

@implementation ProgressDataManager

CWL_SYNTHESIZE_SINGLETON_FOR_CLASS(ProgressDataManager);

- (id) init {
    
    self = [super init];
    if(self != nil) {
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"progressData"];
        if (data != nil) {
            NSDictionary *extractedDic = [NSKeyedUnarchiver unarchiveObjectWithData:data] ;
            
            
            progressDictionary = [extractedDic mutableCopy];
        } else {
            progressDictionary = [[NSMutableDictionary alloc] init];
        }
    }
    return self;
}

- (void) saveProgressData {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:progressDictionary];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"progressData"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) initProgressForDownloadItem:(DownloadItem *)downloadItem {
    if([progressDictionary objectForKey:downloadItem.key] == nil) {
        [progressDictionary setObject:downloadItem forKey:downloadItem.key];
    }
}

- (void) storeProgress:(float)progress key:(NSString *)key {
    DownloadItem *di = [progressDictionary objectForKey:key];
    if(di != nil) {
        di.progress = progress;
    }
}

- (void) resetProgress:(NSString *)key {
    [progressDictionary removeObjectForKey:key];
}

- (void) updateProgress:(NSString *)key updateBlock:(void(^)(float))updateBlock {
    DownloadItem *di = [progressDictionary objectForKey:key];
    if(di != nil) {
        updateBlock(di.progress);
    }
}

- (NSArray *) storedKeys {
    return [[progressDictionary allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
}

- (DownloadItem *) downloadItem:(NSString *)key {
    return [progressDictionary objectForKey:key];
}

- (void) clear {
    [progressDictionary removeAllObjects];
}

@end
