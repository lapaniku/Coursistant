//
//  ILectureDelegate.h
//  Coursistant Sceleton
//
//  Created by Andrew on 27.12.12.
//  Copyright (c) 2012 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IContentDelegate <NSObject>

@required
- (void) contentExtracted:(NSArray *)items;
- (void) contentError:(NSError *)error;
- (void) notifyDelay;

@end
