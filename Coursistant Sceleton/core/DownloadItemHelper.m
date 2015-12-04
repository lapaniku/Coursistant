//
//  DownloadItemHelper.m
//  Coursistant
//
//  Created by Andrei Lapanik on 24.03.14.
//  Copyright (c) 2014 Altasapiens. All rights reserved.
//

#import "DownloadItemHelper.h"


@implementation DownloadItemHelper

+(DownloadItem *) createSubtitleDownloadItem:(NSDictionary*)subtitleData stencil:(DownloadItem *)stencil {
    NSString *link = [subtitleData objectForKey:@"link"];
    NSString *subtitleName = [[link  stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] lastPathComponent];
    NSArray *items = [subtitleName componentsSeparatedByString:@"_"];
    NSString *languageCode = (items.count > 1) ? [items objectAtIndex:1] : nil;
    
    
    DownloadItem *di = [DownloadItemHelper createSubtitleDownloadItemStub:languageCode stencil:stencil];
    di.key = link;
    di.url = [NSURL URLWithString:link];
    
    return di;
}

+(DownloadItem *) createSubtitleDownloadItemStub:(NSString *)languageCode stencil:(DownloadItem *)stencil {
    DownloadItem *di = [stencil mutableCopy];
    
    if(languageCode != nil && ![languageCode isEqualToString:@""]) {
        di.extension = [[@"subtitles." stringByAppendingString:languageCode] stringByAppendingString:@".srt"];
    } else {
        di.extension = @"subtitles.???.srt";
    }
    
    return di;

}

@end
