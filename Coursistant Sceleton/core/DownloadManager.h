//
//  DownloadService.h
//  Coursistant Sceleton
//
//  Created by Andrew on 14.03.13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CWLSynthesizeSingleton.h"
#import "DownloadItem.h"
#import "AFDownloadRequestOperation.h"

typedef void (^DownloadProgressBlock) (AFDownloadRequestOperation *operation, NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpected, long long totalBytesReadForFile, long long totalBytesExpectedToReadForFile);

typedef void (^SuccessCompletionBlock) (AFHTTPRequestOperation *operation, id responseObject);

typedef void (^FailureCompletionBlock) (AFHTTPRequestOperation *operation, NSError *error);

@interface DownloadManager : NSObject {
    NSOperationQueue *manualDownloadQueue;
    NSMutableDictionary *manualDownloadOperationDictionary;

    NSMutableDictionary *autoDownloadQueueDictionary;
    NSMutableDictionary *autoDownloadOperationDictionary;

    NSOperationQueue *resourceDownloadQueue;
    NSMutableDictionary *resourceDownloadOperationDictionary;

}

CWL_DECLARE_SINGLETON_FOR_CLASS(DownloadManager)

- (void) manualDownload:(DownloadItem *)downloadItem downloadProgressBlock:(DownloadProgressBlock)downloadProgressBlock successCompletionBlock:(SuccessCompletionBlock)successCompletionBlock failureCompletionBlock:(FailureCompletionBlock)failureCompletionBlock;

- (void) removeOperationByKey:(NSString *)key;

- (void) autoDownload:(NSString *)queueKey downloadItem:(DownloadItem *)downloadItem downloadProgressBlock:(DownloadProgressBlock)downloadProgressBlock successCompletionBlock:(SuccessCompletionBlock)successCompletionBlock failureCompletionBlock:(FailureCompletionBlock)failureCompletionBlock;

- (void) finishAutoDownloadWithBlock:(NSString *)queueKey block:(void (^)(void))block;

- (void) removeAutoDownloadQueue:(NSString *)queueKey;

-(BOOL) isItemDownloaded:(DownloadItem *)downloadItem;

+(NSString *) folderPath:(NSString *)provider courseTitle:(NSString *)courseTitle;

+(NSString *) filePath:(DownloadItem *)downloadItem;

- (void) deleteItem:(DownloadItem *)downloadItem;

- (BOOL) isQueueActive:(NSString *)queueKey;

- (BOOL) isItemEnqueued:(DownloadItem *)downloadItem;

- (BOOL) isItemSingle:(DownloadItem *)downloadItem;

- (BOOL) isOperationCreatedFor:(DownloadItem *)downloadItem;

- (AFDownloadRequestOperation *) operationForItem:(DownloadItem *)downloadItem;

- (NSInteger) downloadOperationCount;

- (void) pauseAll:(void(^)(NSString *key))pauseBlock;

- (void) resumeAll:(void(^)(NSString *key))resumeBlock;

- (NSArray *) allActiveKeys;

- (BOOL) isAnyOperationActive;

- (void) subtitleDownload:(DownloadItem *)downloadItem completionBlock:(void(^)(void))completionBlock;

- (void) resourceDownload:(DownloadItem *)downloadItem downloadProgressBlock:(DownloadProgressBlock)downloadProgressBlock successCompletionBlock:(SuccessCompletionBlock)successCompletionBlock failureCompletionBlock:(FailureCompletionBlock)failureCompletionBlock;

-(void) convertDocFolderForWindows;

@end
