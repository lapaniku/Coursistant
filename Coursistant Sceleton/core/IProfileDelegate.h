//
//  IProfileDelegate.h
//  Coursistant Sceleton
//
//  Created by Andrew on 21.12.12.
//  Copyright (c) 2012 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IProfileDelegate <NSObject>

@required
- (void) profileExtracted:(NSArray *)courses newCources:(NSArray *)newCources;
- (void) profileError:(NSError *)error code:(NSString*)code;

@end
