//
//  ParserManager.m
//  Coursistant
//
//  Created by Andrew on 06.09.13.
//  Copyright (c) 2013 Altasapiens. All rights reserved.
//

#import "ParserManager.h"
#import "NSFileManager+DirectoryLocations.h"
#import <CommonCrypto/CommonDigest.h>
#import "AFHTTPRequestOperation.h"
#import "AFDownloadRequestOperation.h"
#import "ZipArchive.h"
#import "OfflineDataManager.h"
#import "AlertViewBlocks.h"
#import <EXTScope.h>

@implementation ParserManager

CWL_SYNTHESIZE_SINGLETON_FOR_CLASS(ParserManager);

#define BASE_URL @"http://coursistant.com"
#define REMOTE_PATH @"/parser/parser.zip"
#define BUNDLE_NAME @"parser"

@synthesize delegate;

static double HALF_AN_HOUR = 30*60.0;

- (id) init {
    
    self = [super init];
    httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:BASE_URL]];
    [httpClient setAuthorizationHeaderWithUsername:@"coursistant" password:@"Qwerty123"];
    return self;
}

-(void) reloadCode {
    
    finished = false;
    
    [self syncWithBundle];
    
    if([OfflineDataManager sharedOfflineDataManager].online && !finished) {
        NSMutableURLRequest *request = [httpClient requestWithMethod:@"GET" path:REMOTE_PATH parameters:nil];
        [request setHTTPMethod:@"HEAD"];
        AFHTTPRequestOperation *headOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        @weakify(self)
        [headOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            //        NSDictionary *fields = [[operation response] allHeaderFields];
            NSString * last_modified = [NSString stringWithFormat:@"%@",
                                        [[[operation response] allHeaderFields] objectForKey:@"Last-Modified"]];
            @strongify(self)
            [self updateParser:last_modified];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            @strongify(self)
            [self finishUpdate];
        }];
        [httpClient enqueueHTTPRequestOperation:headOperation];
        [NSTimer scheduledTimerWithTimeInterval: 30.0
                                         target:self
                                       selector:@selector(cancelReload)
                                       userInfo:nil
                                        repeats: NO];
    } else {
        [self finishUpdate];
    }
}

-(void) syncWithBundle {
    NSString *script = [REMOTE_PATH lastPathComponent];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *localPath = [[fileManager applicationSupportDirectory] stringByAppendingPathComponent:script];
    NSError *error = nil;
    if(![fileManager fileExistsAtPath:localPath]) {
        error = [self copyFromBundleTo:localPath];
        if(error) {
            [self finishUpdate];
        }
    } else {
        NSDate *fileDate;
        NSDictionary *attributes = [fileManager attributesOfItemAtPath:localPath error:&error];
        
        if (attributes != nil) {
            fileDate = (NSDate*)[attributes objectForKey: NSFileModificationDate];
        }
        NSDate *bundleDate;
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:BUNDLE_NAME ofType:@"zip"];
        attributes = [fileManager attributesOfItemAtPath:bundlePath error:&error];
        
        if (attributes != nil) {
            bundleDate = (NSDate*)[attributes objectForKey: NSFileModificationDate];
        }
        if(([fileDate compare:bundleDate] == NSOrderedAscending)) {
            error = [self copyFromBundleTo:localPath];
            if(error) {
                [self finishUpdate];
            }
        }
    }
    
}

-(void) updateParser:(NSString *)lastModified {
    NSString *script = [REMOTE_PATH lastPathComponent];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *localPath = [[fileManager applicationSupportDirectory] stringByAppendingPathComponent:script];
    NSError *error = nil;
    
    NSDate *fileDate;
    NSDictionary *attributes = [fileManager attributesOfItemAtPath:localPath error:&error];
    
    if (attributes != nil) {
        fileDate = (NSDate*)[attributes objectForKey: NSFileModificationDate];
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [[NSLocale alloc]
                                  initWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:enUSPOSIXLocale];
//    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [dateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss zzz"];
    
    NSDate *lastModifiedDate = [dateFormatter dateFromString:lastModified];
    if((fileDate == nil) || ([fileDate compare:lastModifiedDate] == NSOrderedAscending)) {
        
        if(lastUpdate == nil) {
            [self downloadThenVerify:localPath usingTempFile:[NSTemporaryDirectory() stringByAppendingPathComponent:script]];
        } else {
            if(![confirmedUpdateDate isEqualToDate:lastModifiedDate]) {
                UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"Parser update is available"
                                                           message:@"You should restart your app to download new parsing scripts that improve access to your courses."
                                                          delegate:nil
                                                 cancelButtonTitle:@"Okay"
                                                 otherButtonTitles:nil];
            
                [alert show];
                confirmedUpdateDate = lastModifiedDate;
            }
        }
    } else {
        [self finishUpdate];
    }
    lastUpdate = [NSDate date];
}

-(void) downloadThenVerify:(NSString *)localPath usingTempFile:(NSString *)tempFile {

    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSError *error;
    if ([fileManager fileExistsAtPath:tempFile]) {
        [fileManager removeItemAtPath:tempFile error:&error];
        if(error) {
            [self finishUpdate];
        }
    }
    NSURLRequest *request = [httpClient requestWithMethod:@"GET" path:REMOTE_PATH parameters:nil];
    AFDownloadRequestOperation *operation = [[AFDownloadRequestOperation alloc] initWithRequest:request targetPath:tempFile shouldResume:NO];
    @weakify(self)
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        @strongify(self)
        [self verifyThenUpdate:localPath fromTemp:tempFile];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        @strongify(self)
        [self finishUpdate];
    }];
    [httpClient enqueueHTTPRequestOperation:operation];
}

-(void) verifyThenUpdate:(NSString *)localPath fromTemp:(NSString *)tempFile {
    
    NSError *error;
    NSData *tempFileContent = [NSData dataWithContentsOfFile:tempFile];

//    NSString *tempFileContent = [NSString stringWithContentsOfFile:tempFile encoding:NSUTF8StringEncoding error:&error];
    if(!error) {
        NSString *md5 = [self md5StringFromData:tempFileContent];
        NSMutableURLRequest *request = [httpClient requestWithMethod:@"GET" path:[REMOTE_PATH stringByAppendingPathExtension:@"md5"] parameters:nil];
        AFHTTPRequestOperation *md5Operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        @weakify(self)
        [md5Operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            @strongify(self)
            NSString *remoteMD5 = [operation.responseString uppercaseString];
            if([md5 isEqualToString:remoteMD5]) {
                [self update:localPath fromTemp:tempFile];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            @strongify(self)
            [self finishUpdate];
        }];
        [httpClient enqueueHTTPRequestOperation:md5Operation];
    } else {
        [self finishUpdate];
    }
}

-(void) update:(NSString *)localPath fromTemp:(NSString *)tempPath{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    if ([fileManager fileExistsAtPath:localPath] == YES) {
        [fileManager removeItemAtPath:localPath error:&error];
        if(error) {
            [self finishUpdate];
        }
    }
    
    [fileManager copyItemAtPath:tempPath toPath:localPath error:&error];
    [self unzipSafely:localPath];
    
    if(!error) {
        [fileManager removeItemAtPath:tempPath error:&error];
    }
    [self finishUpdate];
}

-(void) unzipSafely:(NSString *)zipPath {
    ZipArchive *zipArchive = [[ZipArchive alloc] init];
    [zipArchive UnzipOpenFile:zipPath];
    [zipArchive UnzipFileTo:[zipPath stringByDeletingLastPathComponent] overWrite:YES];
    [zipArchive UnzipCloseFile];
}

-(void) finishUpdate {
    finished = true;
    if(delegate) {
        
        [delegate parserUpdateFinished];
    }
}

-(void) cancelReload {
    if(!finished) {
        [httpClient cancelAllHTTPOperationsWithMethod:@"HEAD" path:REMOTE_PATH];
        [httpClient cancelAllHTTPOperationsWithMethod:@"GET" path:REMOTE_PATH];
        [httpClient cancelAllHTTPOperationsWithMethod:@"GET" path:[REMOTE_PATH stringByAppendingPathExtension:@"md5"]];
        [self finishUpdate];
    }
}

- (NSString *)md5StringFromData:(NSData *)data
{
    void *cData = malloc([data length]);
    unsigned char resultCString[16];
    [data getBytes:cData length:[data length]];
    
    CC_MD5(cData, [data length], resultCString);
    free(cData);
    
    NSString *result = [NSString stringWithFormat:
                        @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
                        resultCString[0], resultCString[1], resultCString[2], resultCString[3],
                        resultCString[4], resultCString[5], resultCString[6], resultCString[7],
                        resultCString[8], resultCString[9], resultCString[10], resultCString[11],
                        resultCString[12], resultCString[13], resultCString[14], resultCString[15]
                        ];
    return result;
}

+(NSString *) script:(NSString *)fileName {
    NSString *scriptPath = [[[NSFileManager defaultManager] applicationSupportDirectory] stringByAppendingPathComponent:[fileName stringByAppendingPathExtension:@"js"]];
    NSError *error;
    NSString *scriptCode = [NSString stringWithContentsOfFile:scriptPath encoding:NSUTF8StringEncoding error:&error];
    if(error) {
        scriptCode = @"return {};";
    }
    return scriptCode;
}

-(NSError *) copyFromBundleTo:(NSString *)localPath {
    NSError *error;
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:BUNDLE_NAME ofType:@"zip"];
    NSData *data = [NSData dataWithContentsOfFile:bundlePath];
    [data writeToFile:localPath options:NSDataWritingAtomic error:&error];
    [self unzipSafely:localPath];
    return error;
}

-(void) startPeriodicUpdate {
    periodicUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:HALF_AN_HOUR
                                     target:self
                                   selector:@selector(reloadCode)
                                   userInfo:nil
                                    repeats:YES];
    if(lastUpdate == nil || -[lastUpdate timeIntervalSinceNow] >= HALF_AN_HOUR) {
        [self reloadCode];
    }
}

-(void) stopPeriodicUpdate {
    [periodicUpdateTimer invalidate];
    periodicUpdateTimer = nil;
}

@end
