//
//  CourseraProfileManager.m
//  Coursistant Sceleton
//
//  Created by Andrew on 21.02.13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import "CourseraProfileManager.h"
#import "CourseraLinks.h"
#import "CSTJSONRequestOperation.h"
#import "JSParser.h"
#import "OfflineDataManager.h"
#import "ParserManager.h"


@implementation CourseraProfileManager

@synthesize delegate;

- (id) init: (id <IProfileDelegate>) aDelegate
{
    self = [super init];
    self.delegate = aDelegate;
    return self;
}

- (void) readProfile:(NSString *)aUserID {
    
    if([OfflineDataManager sharedOfflineDataManager].online) {
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[CourseraLinks ProfileURL:aUserID]];
        [request setValue:@"https://www.coursera.org" forHTTPHeaderField:@"Referer"];
        [request setValue:@"XMLHttpRequest" forHTTPHeaderField:@"X-Requested-With"];

        CSTJSONRequestOperation *operation = [CSTJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id json) {
            
            JSParser *jsparser = [[JSParser alloc] init:[ParserManager script:@"CourseraProfileParser"]];
            NSArray *profile = [jsparser parseArray:json];
            NSArray *newCourses = [[OfflineDataManager sharedOfflineDataManager] updateProfileFor:@"Coursera" profile:profile];
            [delegate profileExtracted:profile newCources:newCourses];
            
            
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
            if([OfflineDataManager isConnectionNotAvailableError:error]) {
                
                [self useOfflineData];
            } else {
                
                [delegate profileError:error code:[@"Coursera" stringByAppendingString:[@(response.statusCode) description]]];
            }
            
        } responseFilter:nil];
        
        
        [[OperationService sharedOperationService] manageOperation:operation owner:self];
    } else {
        [self useOfflineData];
    }
}

-(void) useOfflineData {
    NSArray *profile = [[OfflineDataManager sharedOfflineDataManager] profileFor:@"Coursera"];
    if(profile != nil) {
        [delegate profileExtracted:profile newCources:nil];
    } else {
        NSString *message = [NSString stringWithFormat:@"No data stored for Coursera provider"];
        NSError *error = [[NSError alloc] initWithDomain:message code:-1 userInfo:nil];
        
        [delegate profileError:error code:nil];
    }
}

@end
