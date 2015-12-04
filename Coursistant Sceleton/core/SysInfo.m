//
//  SysInfo.m
//  Coursistant
//
//  Created by Andrew on 13.09.13.
//  Copyright (c) 2013 Altasapiens. All rights reserved.
//

#import "SysInfo.h"
#import <UIKit/UIDevice.h>

#import <stdio.h>
#import <string.h>

#import <mach/mach_host.h>
#import <sys/sysctl.h>
#import <mach/mach.h>

@implementation SysInfo

+(NSString *) deviceInfo {
    UIDevice *currentDevice = [UIDevice currentDevice];
    return [[NSString alloc] initWithFormat:@"Model: %@ / System: %@ %@", [self platformString],  currentDevice.systemName, currentDevice.systemVersion];
}

// http://iphonesdkdev.blogspot.com/2009/01/source-code-get-hardware-info-of-iphone.html
+(NSString *) memoryInfo {
    
    size_t length;
    int mib[6];
    unsigned int result;
    
    int pagesize;
    mib[0] = CTL_HW;
    mib[1] = HW_PAGESIZE;
    length = sizeof(pagesize);
    if (sysctl(mib, 2, &pagesize, &length, NULL, 0) < 0) {
        return @"page size error";
    }
    
    mach_msg_type_number_t count = HOST_VM_INFO_COUNT;
    
    vm_statistics_data_t vmstat;
    if (host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vmstat, &count) != KERN_SUCCESS) {
        return @"Failed to get VM statistics.";
    }
    
    double total = vmstat.wire_count + vmstat.active_count + vmstat.inactive_count + vmstat.free_count;
    double wired = vmstat.wire_count / total;
    double active = vmstat.active_count / total;
    double inactive = vmstat.inactive_count / total;
    double free = vmstat.free_count / total;
    
    NSMutableString *str = [[NSMutableString alloc] init];
//    [str appendString:[[NSString alloc] initWithFormat:@"Total = %8d pages\n\n", vmstat.wire_count + vmstat.active_count + vmstat.inactive_count + vmstat.free_count]];
//    [str appendString:[[NSString alloc] initWithFormat:@"Wired = %8d bytes\n", vmstat.wire_count * pagesize]];
//    [str appendString:[[NSString alloc] initWithFormat:@"Active = %8d bytes\n", vmstat.active_count * pagesize]];
//    [str appendString:[[NSString alloc] initWithFormat:@"Inactive = %8d bytes\n", vmstat.inactive_count * pagesize]];
//    [str appendString:[[NSString alloc] initWithFormat:@"Free = %8d bytes\n\n", vmstat.free_count * pagesize]];
    [str appendString:[[NSString alloc] initWithFormat:@"Total = %8d Mb", (vmstat.wire_count + vmstat.active_count + vmstat.inactive_count + vmstat.free_count) * pagesize / (1024 * 1024)]];
    [str appendString:[[NSString alloc] initWithFormat:@" / Wired = %0.2f %%", wired * 100.0]];
    [str appendString:[[NSString alloc] initWithFormat:@" / Active = %0.2f %%", active * 100.0]];
    [str appendString:[[NSString alloc] initWithFormat:@" / Inactive = %0.2f %%", inactive * 100.0]];
    [str appendString:[[NSString alloc] initWithFormat:@" / Free = %0.2f %%", free * 100.0]];
    
    mib[0] = CTL_HW;
    mib[1] = HW_PHYSMEM;
    length = sizeof(result);
    if (sysctl(mib, 2, &result, &length, NULL, 0) < 0) {
        return @"error getting physical memory";
    }
    [str appendString:[[NSString alloc] initWithFormat:@" / Physical memory = %8d Mb", result / (1024 * 1024)]];
    mib[0] = CTL_HW;
    mib[1] = HW_USERMEM;
    length = sizeof(result);
    if (sysctl(mib, 2, &result, &length, NULL, 0) < 0) {
        return @"error getting user memory";
    }

    [str appendString:[[NSString alloc] initWithFormat:@" / User memory = %8d Mb", result / (1024 * 1024)]];
    
    return str;
}

+ (NSString *) platform{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithUTF8String:machine];
    free(machine);
    return platform;
}

// http://stackoverflow.com/questions/448162/determine-device-iphone-ipod-touch-with-iphone-sdk
+ (NSString *) platformString{
    NSString *platform = [self platform];
    if ([platform isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([platform isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"])    return @"Verizon iPhone 4";
    if ([platform isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([platform isEqualToString:@"iPhone5,1"])    return @"iPhone 5 (GSM)";
    if ([platform isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([platform isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([platform isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([platform isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([platform isEqualToString:@"iPod5,1"])      return @"iPod Touch 5G";
    if ([platform isEqualToString:@"iPad1,1"])      return @"iPad 1";
    if ([platform isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    if ([platform isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([platform isEqualToString:@"iPad2,4"])      return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
    if ([platform isEqualToString:@"iPad2,6"])      return @"iPad Mini (GSM)";
    if ([platform isEqualToString:@"iPad2,7"])      return @"iPad Mini (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    if ([platform isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad3,3"])      return @"iPad 3 (GSM)";
    if ([platform isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([platform isEqualToString:@"iPad3,5"])      return @"iPad 4 (GSM)";
    if ([platform isEqualToString:@"iPad3,6"])      return @"iPad 4 (GSM+CDMA)";
    if ([platform isEqualToString:@"i386"])         return @"Simulator";
    if ([platform isEqualToString:@"x86_64"])       return @"Simulator";
    return platform;
}

// http://stackoverflow.com/questions/787160/programmatically-retrieve-memory-usage-on-iphone
+(NSString *) reportMemory {
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    kern_return_t kerr = task_info(mach_task_self(),
                                   TASK_BASIC_INFO,
                                   (task_info_t)&info,
                                   &size);
    if( kerr == KERN_SUCCESS ) {
        return [[NSString alloc] initWithFormat:@"Memory in use: %u Mb", info.resident_size / (1024 * 1024) ];
    } else {
        return [[NSString alloc] initWithFormat:@"Error with task_info(): %s", mach_error_string(kerr) ];
    }
}

// http://stackoverflow.com/questions/5199582/show-available-physical-memory-on-device-iphone-ipad
+(NSString *) spaceInfo {
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSDictionary *info = [[NSFileManager defaultManager] attributesOfFileSystemForPath:path error:NULL];
    NSUInteger totalSpace = [[info objectForKey:NSFileSystemSize] unsignedIntegerValue] / (1024 * 1024);
    NSUInteger freeSpace = [[info objectForKey:NSFileSystemFreeSize] unsignedIntegerValue] / (1024*1024);
    
    return [[NSString alloc] initWithFormat:@"Total space: %d Mb / Free space: %d Mb", totalSpace, freeSpace];
}

@end
