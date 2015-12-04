//
//  BasicJSONManager.m
//  Coursistant
//
//  Created by Andrew on 23.08.13.
//  Copyright (c) 2013 Altasapiens. All rights reserved.
//

#import "BasicJSONManager.h"
#import "IContentParser.h"
#import "OfflineDataManager.h"
#import "CSTJSONRequestOperation.h"
#import "OperationService.h"




@implementation BasicJSONManager
{
    NSMutableData *receivedData;
    NSTimer *timer;
}


@synthesize delegate, parser;
@synthesize onlineDataHandler, offlineDataHandler;
    
-(id) init:(id <IContentDelegate>)aDelegate parser:(id<IContentParser>)aParser
{
    self = [super init];
    self.delegate = aDelegate;
    self.parser = aParser;
    return self;

}

-(void) readContent:(NSURL *)requestURL title:(NSString *)title {
    
    if([OfflineDataManager sharedOfflineDataManager].online) {
      
        timer = [NSTimer scheduledTimerWithTimeInterval: 32.0
                                                 target: self
                                               selector: @selector(notifyDelay:)
                                               userInfo: nil
                                                repeats: NO];
        
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:requestURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:62.0];

        
        
        CSTJSONRequestOperation *operation = [CSTJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
            
            [self invalidateFirstTimer];
            NSArray *contentData = [parser parseArray:JSON];
            if(onlineDataHandler != nil) {
                onlineDataHandler(title, contentData);
            }
            
            [delegate contentExtracted:contentData];
            
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
            
            [self invalidateFirstTimer];
            if([OfflineDataManager isConnectionNotAvailableError:error]) {
                [self useOfflineData:title];
            } else {
                [delegate contentError:error];
            }
        } responseFilter:^(NSData* response) {
            
            if(response == nil) {
                return (NSData*)nil;
            } else {
                NSArray *responseLines = [[[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding] componentsSeparatedByString:@"\n"];
                return [responseLines count] < 1 ? response : [[responseLines objectAtIndex:1] dataUsingEncoding:NSUTF8StringEncoding];
            }
            
        }];
        
        [[OperationService sharedOperationService] manageOperation:operation owner:self];
        
   
        
        
    } else {
        
        [self useOfflineData:title];
    }
}

- (void)notifyDelay:(NSTimer *)timerP {

    [delegate notifyDelay];
    [self invalidateFirstTimer];
}

- (void)invalidateFirstTimer{

    [timer invalidate];
    timer=nil;
}

//- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
//{
//    // This method is called when the server has determined that it
//    // has enough information to create the NSURLResponse.
//    
//    // It can be called multiple times, for example in the case of a
//    // redirect, so each time we reset the data.
//    
//    // receivedData is an instance variable declared elsewhere.
//    [receivedData setLength:0];
//}
//
//- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
//{
//    // Append the new data to receivedData.
//    // receivedData is an instance variable declared elsewhere.
//    [receivedData appendData:data];
//}




//- (void)connectionDidFinishLoading:(NSURLConnection *)connection
//{
//    // do something with the data
//    // receivedData is declared as a method instance elsewhere
//    NSLog(@"Succeeded! Received %d bytes of data",[receivedData length]);
//    
//    // release the connection, and the data object
//
//}

-(void) useOfflineData:(NSString *)title {
    if(offlineDataHandler != nil) {
        NSArray *contentData = offlineDataHandler(title);
        if(contentData != nil) {
            [delegate contentExtracted:contentData];
        } else {
            NSString *message = [NSString stringWithFormat:@"No data stored for course \"%@.\"", title];
            NSError *error = [[NSError alloc] initWithDomain:message code:-1 userInfo:nil];
            [delegate contentError:error];
        }
    }
}

@end
