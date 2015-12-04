//
//  CSTUnitedProfile.m
//  Coursistant Sceleton
//
//  Created by Администратор on 29.3.13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import "CSTUnitedProfile.h"
#import "UdacityProviderService.h"
#import "CourseraProviderService.h"

@implementation CSTUnitedProfile

CWL_SYNTHESIZE_SINGLETON_FOR_CLASS(CSTUnitedProfile);

@synthesize expectedRequestCount;
@synthesize courses;
@synthesize addedCourses;
@synthesize delegate;
@synthesize errorMessage;

-(id) init {
    self = [super init];
    
    self.courses = [[NSMutableArray alloc] init];
    self.addedCourses = [[NSMutableArray alloc] init];
    
    return self;
}

-(void) renew:(id<UnitedProfileDelegate>) aDelegate {
    delegate = aDelegate;
    expectedRequestCount = 0;
    [courses removeAllObjects];
    [addedCourses removeAllObjects];
    self.httpResponseCode = @"";
    self.errorMessage = nil;
}

//iprofile delegate
-(void) profileExtracted:(NSArray *)extractedCourses newCources:(NSArray *)aNewCourses{
    
    if(expectedRequestCount > 0) {
        expectedRequestCount--;
        
        if(extractedCourses.count > 0) {
            if((courses.count > 0) && ([[[extractedCourses objectAtIndex:0] valueForKey:@"provider"] compare:[[courses objectAtIndex:0] valueForKey:@"provider"] options:NSCaseInsensitiveSearch] == NSOrderedAscending)) {
                
                
                [courses insertObjects:extractedCourses atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, extractedCourses.count)]];
            } else {
                [courses addObjectsFromArray:extractedCourses];
            }
            
        }
        if(aNewCourses != nil) {
            [addedCourses addObjectsFromArray:aNewCourses];
        }
        if(expectedRequestCount == 0) {
            [delegate unitedProfileExtracted:courses newCourses:addedCourses errorMessage:errorMessage];
        }
    }
}

-(void) profileError:(NSError *)error code:(NSString *)code {
    
    self.httpResponseCode = code;
    if(expectedRequestCount > 0) {
        expectedRequestCount--;
        
        if(errorMessage == nil) {
            errorMessage = [[NSString alloc] initWithFormat: @"Poor response from provider: \"%@\". Try to refresh and check if coursera.org/udacity.com are avialble via browser. Also, you can try offline mode and set Coursistant back to online after this rush hour.", [error localizedDescription]];
        } else {
            errorMessage = @"Poor response from provider. Try to refresh and check if coursera.org/udacity.com are avialble via browser. Also, you can try offline mode and set Coursistant back to online after this rush hour.";
        }
        if(expectedRequestCount == 0) {
            [delegate unitedProfileExtracted:courses newCourses:addedCourses errorMessage:errorMessage];
        }
    }
}

-(NSString *) coursesDescription {
    
    NSMutableString *result = [[NSMutableString alloc] init];
    for (NSDictionary *course in courses) {
        [result appendFormat:@"%@ / %@", [course objectForKey:@"provider"], [course objectForKey:@"title"] ];
        if(![course isEqualToDictionary:[courses lastObject]]) {
            [result appendString:@"; "];
        }
    }
    return result;
}

@end
