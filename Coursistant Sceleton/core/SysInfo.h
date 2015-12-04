//
//  SysInfo.h
//  Coursistant
//
//  Created by Andrew on 13.09.13.
//  Copyright (c) 2013 Altasapiens. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SysInfo : NSObject

+(NSString *) deviceInfo;

+(NSString *) memoryInfo;

+(NSString *) reportMemory;

+(NSString *) spaceInfo;

@end
