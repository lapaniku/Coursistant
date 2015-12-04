//
//  ProgressDataManager.h
//  Coursistant Sceleton
//
//  Created by Andrew on 18.06.13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CWLSynthesizeSingleton.h"
#import "DownloadItem.h"

@interface ProgressDataManager : NSObject {
    
    NSMutableDictionary *progressDictionary;
}

CWL_DECLARE_SINGLETON_FOR_CLASS(ProgressDataManager)

- (void) saveProgressData;

- (void) initProgressForDownloadItem:(DownloadItem *)downloadItem;

- (void) storeProgress:(float)progress key:(NSString *)key;

- (void) resetProgress:(NSString *)key;

- (void) updateProgress:(NSString *)key updateBlock:(void(^)(float))updateBlock;

- (NSArray *) storedKeys;

- (DownloadItem *) downloadItem:(NSString *)key;

- (void) clear;

@end
