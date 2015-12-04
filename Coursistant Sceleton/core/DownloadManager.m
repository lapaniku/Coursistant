//
//  DownloadService.m
//  Coursistant Sceleton
//
//  Created by Andrew on 14.03.13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import "DownloadManager.h"
#import "CWLSynthesizeSingleton.h"
#import "CSTDownloadControlButton.h"
#import "ProgressDataManager.h"


@implementation DownloadManager

CWL_SYNTHESIZE_SINGLETON_FOR_CLASS(DownloadManager);

-(id) init {
    self = [super init];
    manualDownloadQueue = [[NSOperationQueue alloc] init];
    resourceDownloadQueue = [[NSOperationQueue alloc] init];
    return self;
}

-(AFDownloadRequestOperation *) createDownloadOperation:(NSString *)key url:(NSURL *)url filePath:(NSString *)filePath downloadProgressBlock:(DownloadProgressBlock)downloadProgressBlock successCompletionBlock:(SuccessCompletionBlock)successCompletionBlock failureCompletionBlock:(FailureCompletionBlock)failureCompletionBlock {
    
    [self createPathFoldersIfNotExist:filePath];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFDownloadRequestOperation *operation = [[AFDownloadRequestOperation alloc] initWithRequest:request targetPath:filePath shouldResume:YES];
//    DownloadOperation *operation = [[DownloadOperation alloc] init:request filePath:filePath];
    
    if(downloadProgressBlock != nil) {
        [operation setProgressiveDownloadProgressBlock:downloadProgressBlock];
    }
    if((failureCompletionBlock != nil) && (successCompletionBlock != nil)) {
    [operation setCompletionBlockWithSuccess:successCompletionBlock failure:failureCompletionBlock];
    }
        
    __block AFDownloadRequestOperation *operationInBackground = operation;
    __block NSString *operationKey = key;
    [operation setShouldExecuteAsBackgroundTaskWithExpirationHandler:^{
        [operationInBackground cancel];
        [[ProgressDataManager sharedProgressDataManager] saveProgressData];
        [self removeOperationByKey:operationKey];
        [[CSTDownloadControlButton sharedCSTDownloadControlButton] resetState];
    }];
       
    return operation;
}


- (void) manualDownload:(DownloadItem *)downloadItem downloadProgressBlock:(DownloadProgressBlock)downloadProgressBlock successCompletionBlock:(SuccessCompletionBlock)successCompletionBlock failureCompletionBlock:(FailureCompletionBlock)failureCompletionBlock {
    
    NSOperation *otherOperation = [autoDownloadOperationDictionary objectForKey:downloadItem.key];
    if(otherOperation == nil || ![otherOperation isExecuting]) {
        NSOperation *manualOperation = [self createDownloadOperation:downloadItem.key url:downloadItem.url filePath:[DownloadManager filePath:downloadItem] downloadProgressBlock:downloadProgressBlock successCompletionBlock:successCompletionBlock failureCompletionBlock:failureCompletionBlock];
        if(manualDownloadOperationDictionary == nil) {
            manualDownloadOperationDictionary = [[NSMutableDictionary alloc] init];
        }
        [manualDownloadOperationDictionary setObject:manualOperation forKey:downloadItem.key];
        [manualDownloadQueue addOperation:manualOperation];
    }
    if(otherOperation != nil) {
        [otherOperation cancel];
        [autoDownloadOperationDictionary removeObjectForKey:downloadItem.key];
    }
}

- (void) enqueueOperation:(NSOperation *)operation queue:(NSOperationQueue *)queue {
    // make operation last in priority
    NSOperation *lastAddedOperation;
    if(queue.operations.count > 0) {
        lastAddedOperation = [queue.operations objectAtIndex:queue.operations.count-1];
    }
    if(lastAddedOperation != nil) {
        [operation addDependency:lastAddedOperation];
    }    
    [queue addOperation:operation];
}

- (void) autoDownload:(NSString *)queueKey downloadItem:(DownloadItem *)downloadItem downloadProgressBlock:(DownloadProgressBlock)downloadProgressBlock successCompletionBlock:(SuccessCompletionBlock)successCompletionBlock failureCompletionBlock:(FailureCompletionBlock)failureCompletionBlock {
    
    // create operation and queue
    NSOperation *operation = [self createDownloadOperation:downloadItem.key url:downloadItem.url filePath:[DownloadManager filePath:downloadItem] downloadProgressBlock:downloadProgressBlock successCompletionBlock:successCompletionBlock failureCompletionBlock:failureCompletionBlock];

    // connect operation and link
    if(autoDownloadOperationDictionary == nil) {
        autoDownloadOperationDictionary = [[NSMutableDictionary alloc] init];
    }
    [autoDownloadOperationDictionary setObject:operation forKey:downloadItem.key];
    
    NSOperationQueue *autoDownloadQueue = [self autoDownloadOperationQueue:queueKey];
    [self enqueueOperation:operation queue:autoDownloadQueue];
}

- (void) finishAutoDownloadWithBlock:(NSString *)queueKey block:(void (^)(void))block {
    NSOperationQueue *autoDownloadQueue = [self autoDownloadOperationQueue:queueKey];
    NSBlockOperation *finalOperation = [NSBlockOperation blockOperationWithBlock:block];
    [self enqueueOperation:finalOperation queue:autoDownloadQueue];
}


- (NSOperationQueue *) autoDownloadOperationQueue:(NSString *)queueKey {
    if(autoDownloadQueueDictionary == nil) {
        autoDownloadQueueDictionary = [[NSMutableDictionary alloc] init];
    }
    NSOperationQueue *autoDownloadQueue = [autoDownloadQueueDictionary objectForKey:queueKey];
    if(autoDownloadQueue == nil) {
        autoDownloadQueue = [[NSOperationQueue alloc] init];
        [autoDownloadQueue setMaxConcurrentOperationCount:1];
        [autoDownloadQueueDictionary setValue:autoDownloadQueue forKey:queueKey];
    }
    return autoDownloadQueue;
}

- (void) removeAutoDownloadQueue:(NSString *)queueKey {
    NSOperationQueue *autoDownloadQueue = [autoDownloadQueueDictionary objectForKey:queueKey];
    if(autoDownloadQueue != nil) {
        [autoDownloadQueue cancelAllOperations];
        [autoDownloadQueueDictionary removeObjectForKey:queueKey];
        for(NSOperation *queueOperation in [autoDownloadQueue operations]) {
            NSArray *temp = [autoDownloadOperationDictionary allKeysForObject:queueOperation];
            if([temp count] > 0) {
                NSString *key = [temp objectAtIndex:0];
                [autoDownloadOperationDictionary removeObjectForKey:key];
            }
        }
        [autoDownloadOperationDictionary removeObjectForKey:queueKey];
    }
}

- (void) removeOperationByKey:(NSString *)key {
    NSOperation *operation = [autoDownloadOperationDictionary objectForKey:key];
    if(operation != nil) {
        if(![operation isCancelled] && ![operation isFinished]) [operation cancel];
        [autoDownloadOperationDictionary removeObjectForKey:key];
    }
    operation = [manualDownloadOperationDictionary objectForKey:key];
    if(operation != nil) {
        if(![operation isCancelled] && ![operation isFinished]) [operation cancel];
        [manualDownloadOperationDictionary removeObjectForKey:key];
    }
}


+(NSString *) filePath:(DownloadItem *)downloadItem {
    
    NSString *folderPath = [DownloadManager folderPath:downloadItem.provider courseTitle:downloadItem.courseTitle];
    NSString *file = [NSString stringWithFormat:@"%@-%@.%@", [DownloadManager convertFileNameForWindows:downloadItem.category], [DownloadManager convertFileNameForWindows:downloadItem.lectureTitle], downloadItem.extension];
    return [folderPath stringByAppendingPathComponent:file];
}

+(NSString *) folderPath:(NSString *)provider courseTitle:(NSString *)courseTitle {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *folder = [NSString stringWithFormat:@"%@-%@", provider, [DownloadManager convertFileNameForWindows:courseTitle]];
    NSString *folderPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:folder];
    return folderPath;
}

+(NSString *)convertFileNameForWindows:(NSString *)fileName{
    fileName = [fileName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    fileName = [fileName stringByReplacingOccurrencesOfString:@"\\" withString:@"_"];
    fileName = [fileName stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    fileName = [fileName stringByReplacingOccurrencesOfString:@":" withString:@"_"];
    fileName = [fileName stringByReplacingOccurrencesOfString:@"*" withString:@"_"];
    fileName = [fileName stringByReplacingOccurrencesOfString:@"?" withString:@"_"];
    fileName = [fileName stringByReplacingOccurrencesOfString:@"\"" withString:@"_"];
    fileName = [fileName stringByReplacingOccurrencesOfString:@"<" withString:@"_"];
    fileName = [fileName stringByReplacingOccurrencesOfString:@">" withString:@"_"];
    fileName = [fileName stringByReplacingOccurrencesOfString:@"|" withString:@"_"];
    
    return fileName;
}

-(void) convertFilesAt:(NSString*)path {
    NSString* file;
    NSDirectoryEnumerator* enumerator = [[NSFileManager defaultManager] enumeratorAtPath:path];
    while (file = [enumerator nextObject])
    {
        // check if it's a directory
        BOOL isDirectory = NO;
        NSString *filePath = [NSString stringWithFormat:@"%@/%@", path, file];
        [[NSFileManager defaultManager] fileExistsAtPath:filePath
                                             isDirectory:&isDirectory];
        if (!isDirectory) {
            NSUInteger folderLocation = [file rangeOfString:@"/"].location;
            if(folderLocation == NSNotFound) {
                NSString *newFile = [DownloadManager convertFileNameForWindows:file];
                if(![newFile isEqualToString:file]) {
                    NSError *error;
                    NSString *newFilePath = [NSString stringWithFormat:@"%@/%@", path, newFile];
                    [[NSFileManager defaultManager] moveItemAtPath:filePath toPath:newFilePath error:&error];
                }
            }
        } else {
            [self convertFilesAt:filePath];
        }
    }
}

-(void) convertFoldersAt:(NSString*)path {
    NSString* file;
    NSDirectoryEnumerator* enumerator = [[NSFileManager defaultManager] enumeratorAtPath:path];
    while (file = [enumerator nextObject])
    {
        // check if it's a directory
        BOOL isDirectory = NO;
        NSString *filePath = [NSString stringWithFormat:@"%@/%@",path,file];
        [[NSFileManager defaultManager] fileExistsAtPath:filePath
                                             isDirectory:&isDirectory];
        if (isDirectory) {
            NSString *newFile = [DownloadManager convertFileNameForWindows:file];
            if(![newFile isEqualToString:file]) {
                NSError *error;
                NSString *newFilePath = [NSString stringWithFormat:@"%@/%@", path, newFile];
                [[NSFileManager defaultManager] moveItemAtPath:filePath toPath:newFilePath error:&error];
            }
        }
    }
}

-(void) convertDocFolderForWindows {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [paths objectAtIndex:0];
    [self convertFoldersAt:documentPath];
    [self convertFilesAt:documentPath];
}

-(void) createPathFoldersIfNotExist:(NSString *)filePath {
    
    NSString *folderPath = [filePath stringByDeletingLastPathComponent];
    if (![[NSFileManager defaultManager] fileExistsAtPath:folderPath]){
        
        NSError* error;
        if(  [[NSFileManager defaultManager] createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:&error]) {
            
            [self addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:folderPath]];
        }
        else
        {
            //NSLog(@"[%@] ERROR: attempting to write create MyFolder directory", [self class]);
            NSAssert( FALSE, @"Failed to create directory maybe out of disk space?");
        }
    }
}

-(BOOL) isItemDownloaded:(DownloadItem *)downloadItem {
    NSString *filePath = [DownloadManager filePath:downloadItem];
    return [[NSFileManager defaultManager] fileExistsAtPath:filePath];
}

- (void) deleteItem:(DownloadItem *)downloadItem {
    NSString *filePath = [DownloadManager filePath:downloadItem];
    return [self deleteFile:filePath];
}

-(void) deleteFile:(NSString *)filePath {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    BOOL fileExists = [fileManager fileExistsAtPath:filePath];
    //NSLog(@"Is deletable file at path: %d", [fileManager isDeletableFileAtPath:filePath]);
    if (fileExists)
    {
        BOOL success = [fileManager removeItemAtPath:filePath error:&error];
//        if (!success) NSLog(@"Error: %@", [error localizedDescription]);
    }
}

- (BOOL) isQueueActive:(NSString *)queueKey {
    return [autoDownloadQueueDictionary objectForKey:queueKey] != nil;
}

- (BOOL) isItemEnqueued:(DownloadItem *)downloadItem {
    NSOperation *operation = [autoDownloadOperationDictionary objectForKey:downloadItem.key];
    return (operation != nil) && ![operation isExecuting];
}

- (BOOL) isItemSingle:(DownloadItem *)downloadItem {
    NSOperation *operation = [manualDownloadOperationDictionary objectForKey:downloadItem.key];
    BOOL operationNotFinished = ![operation isFinished];
    return (operation != nil) && operationNotFinished;
}

-(BOOL) isOperationCreatedFor:(DownloadItem *)downloadItem {
    return [self isItemEnqueued:downloadItem] || [self isItemSingle:downloadItem];
}

- (AFDownloadRequestOperation *) operationForItem:(DownloadItem *)downloadItem {
    AFDownloadRequestOperation *manualOperation = [manualDownloadOperationDictionary objectForKey:downloadItem.key];
    if(manualOperation != nil) {
        return manualOperation;
    } else {
        AFDownloadRequestOperation *autoOperation = [autoDownloadOperationDictionary objectForKey:downloadItem.key];
        if(autoOperation != nil) {
            return autoOperation;
        }
    }
    return nil;
}

- (NSInteger) downloadOperationCount {
    
    NSInteger result = 0;
    for(NSString *key in [autoDownloadOperationDictionary allKeys]) {
        AFDownloadRequestOperation *operation = [autoDownloadOperationDictionary objectForKey:key];
        if(![operation isFinished] && ![operation isCancelled]) {
            result++;
        }
    }
    for(NSString *key in [manualDownloadOperationDictionary allKeys]) {
        AFDownloadRequestOperation *operation = [manualDownloadOperationDictionary objectForKey:key];
        if(![operation isFinished] && ![operation isCancelled]) {
            result++;
        }
    }
    return result;

}

// add blocks

- (void) pauseAll:(void(^)(NSString *key))pauseBlock {
    for(NSString *key in [autoDownloadOperationDictionary allKeys]) {
        AFDownloadRequestOperation *operation = [autoDownloadOperationDictionary objectForKey:key];
        if([operation isExecuting]) {
            [operation pause];
            if(pauseBlock != nil) {
                pauseBlock(key);
            }
        }
    }
    for(NSString *key in [manualDownloadOperationDictionary allKeys]) {
        AFDownloadRequestOperation *operation = [manualDownloadOperationDictionary objectForKey:key];
        if([operation isExecuting]) {
            [operation pause];
            if(pauseBlock != nil) {
                pauseBlock(key);
            }
        }
    }
    for(NSString *key in [resourceDownloadOperationDictionary allKeys]) {
        AFDownloadRequestOperation *operation = [resourceDownloadOperationDictionary objectForKey:key];
        if([operation isPaused]) {
            [operation pause];
            if(pauseBlock != nil) {
                pauseBlock(key);
            }
        }
    }
}

- (void) resumeAll:(void(^)(NSString *key))resumeBlock {
    for(NSString *key in [autoDownloadOperationDictionary allKeys]) {
        AFDownloadRequestOperation *operation = [autoDownloadOperationDictionary objectForKey:key];
        if([operation isPaused]) {
            [operation resume];
            if(resumeBlock != nil) {
                resumeBlock(key);
            }
        }
    }
    for(NSString *key in [manualDownloadOperationDictionary allKeys]) {
        AFDownloadRequestOperation *operation = [manualDownloadOperationDictionary objectForKey:key];
        if([operation isPaused]) {
            [operation resume];
            if(resumeBlock != nil) {
                resumeBlock(key);
            }
        }
    }
    for(NSString *key in [resourceDownloadOperationDictionary allKeys]) {
        AFDownloadRequestOperation *operation = [resourceDownloadOperationDictionary objectForKey:key];
        if([operation isPaused]) {
            [operation resume];
            if(resumeBlock != nil) {
                resumeBlock(key);
            }
        }
    }
}

- (NSArray *) allActiveKeys {
    return manualDownloadOperationDictionary != nil ? [[manualDownloadOperationDictionary allKeys] arrayByAddingObjectsFromArray:[autoDownloadOperationDictionary allKeys]] : [[autoDownloadOperationDictionary allKeys] arrayByAddingObjectsFromArray:[manualDownloadOperationDictionary allKeys]];
}

- (BOOL) isAnyOperationActive {
    for(NSString *key in [autoDownloadOperationDictionary allKeys]) {
        AFDownloadRequestOperation *operation = [autoDownloadOperationDictionary objectForKey:key];
        if(![operation isFinished] && ![operation isCancelled] && ![operation isPaused]) {
            return YES;
        }
    }
    for(NSString *key in [manualDownloadOperationDictionary allKeys]) {
        AFDownloadRequestOperation *operation = [manualDownloadOperationDictionary objectForKey:key];
        if(![operation isFinished] && ![operation isCancelled] && ![operation isPaused]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL {
    
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
    
    NSError *error = nil;
    
    
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                    
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
        
    }
    
    return success;
}

- (void) subtitleDownload:(DownloadItem *)downloadItem completionBlock:(void(^)(void))completionBlock {
    
    NSOperation *subtitleOperation = [self createDownloadOperation:downloadItem.key url:downloadItem.url filePath:[DownloadManager filePath:downloadItem] downloadProgressBlock:nil successCompletionBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(completionBlock != nil) {
            completionBlock();
        }
    } failureCompletionBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(completionBlock != nil) {
            completionBlock();
        }
    }];
    [manualDownloadQueue addOperation:subtitleOperation];
}

- (void) resourceDownload:(DownloadItem *)downloadItem downloadProgressBlock:(DownloadProgressBlock)downloadProgressBlock successCompletionBlock:(SuccessCompletionBlock)successCompletionBlock failureCompletionBlock:(FailureCompletionBlock)failureCompletionBlock {
    
    NSOperation *resourceOperation = [self createDownloadOperation:downloadItem.key url:downloadItem.url filePath:[DownloadManager filePath:downloadItem] downloadProgressBlock:downloadProgressBlock successCompletionBlock:successCompletionBlock failureCompletionBlock:failureCompletionBlock];
    if(resourceDownloadOperationDictionary == nil) {
        resourceDownloadOperationDictionary = [[NSMutableDictionary alloc] init];
    }
    [resourceDownloadOperationDictionary setObject:resourceOperation forKey:downloadItem.key];
    [resourceDownloadQueue addOperation:resourceOperation];
}

@end
