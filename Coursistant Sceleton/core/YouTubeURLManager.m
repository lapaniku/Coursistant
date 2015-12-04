//
//  VideoLinkManager.m
//  Coursistant Sceleton
//
//  Created by Andrew on 22.05.13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import "YouTubeURLManager.h"
#import "LBYouTubeExtractor.h"

@implementation YouTubeURLManager

- (id) init {
    
    self = [super init];
    urlDictionary = [[NSMutableDictionary alloc] init];
    return self;
}

- (void) loadURLS:(NSArray *)urls completionBlock:(void (^)(void))completionBlock {

    __block NSInteger count = 0;
    for (NSURL *url in urls) {
        if([urlDictionary objectForKey:url] == nil) {
            count++;
            LBYouTubeExtractor *youtubeExtractor = [[LBYouTubeExtractor alloc] initWithURL:url quality:LBYouTubeVideoQualityLarge];
            [youtubeExtractor extractVideoURLWithCompletionBlock:^(NSURL *videoURL, NSError *error) {
                count--;
                if(error == nil) {
                    [self updateVideoURL:url actualURL:videoURL];
                } else {
                    [self updateVideoURL:url actualURL:nil];
                }
                if(count == 0) {
                    completionBlock();
                }
            }];
        }
    }
    if(count == 0) {
        completionBlock();
    }
}

- (void) updateVideoURL:(NSURL *)originalURL actualURL:(NSURL *)actualURL {
    
    if(actualURL != nil) {
        [urlDictionary setObject:actualURL forKey:originalURL];
    } else {
        [urlDictionary setObject:[NSNull null] forKey:originalURL];
    }
}

- (NSURL *) videoURL:(NSURL *)originalURL {
    return [urlDictionary objectForKey:originalURL];
}

@end
