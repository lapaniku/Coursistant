//
//  ParserManager.h
//  Coursistant
//
//  Created by Andrew on 06.09.13.
//  Copyright (c) 2013 Altasapiens. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IParserDelegate.h"
#import "AFHTTPClient.h"
#import "CWLSynthesizeSingleton.h"

@interface ParserManager : NSObject {
    AFHTTPClient *httpClient;
    BOOL finished;
    
    NSDate *lastUpdate;
    NSTimer *periodicUpdateTimer;
    NSDate *confirmedUpdateDate;
}

CWL_DECLARE_SINGLETON_FOR_CLASS(ParserManager)

@property(nonatomic, assign) id <IParserDelegate> delegate;

- (id) init;

-(void) reloadCode;

+(NSString *) script:(NSString *)fileName;

-(void) startPeriodicUpdate;

-(void) stopPeriodicUpdate;

@end
