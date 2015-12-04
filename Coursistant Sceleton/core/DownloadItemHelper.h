//
//  DownloadItemHelper.h
//  Coursistant
//
//  Created by Andrei Lapanik on 24.03.14.
//  Copyright (c) 2014 Altasapiens. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DownloadItem.h"

@interface DownloadItemHelper : NSObject

+(DownloadItem *) createSubtitleDownloadItem:(NSDictionary*)subtitleData stencil:(DownloadItem *)stencil;

+(DownloadItem *) createSubtitleDownloadItemStub:(NSString *)languageCode stencil:(DownloadItem *)stencil;
@end
