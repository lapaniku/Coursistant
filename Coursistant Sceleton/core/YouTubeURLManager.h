//
//  VideoLinkManager.h
//  Coursistant Sceleton
//
//  Created by Andrew on 22.05.13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LBYouTubeExtractor.h"

@interface YouTubeURLManager : NSObject {
    
    NSMutableDictionary *urlDictionary;
}

- (void) loadURLS:(NSArray *)urls completionBlock:(void (^)(void))completionBlock;

- (NSURL *) videoURL:(NSURL *)originalURL;

@end
