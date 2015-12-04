//
//  CSTOnlineBarButton2.m
//  Coursistant Sceleton
//
//  Created by Администратор on 10.5.13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)

#import "CSTOnlineBarButton2.h"

#import "UIImage+iPhone5.h"
#import "OfflineDataManager.h"
#import <QuartzCore/QuartzCore.h>
#import "DownloadManager.h"
#import "Flurry.h"

@implementation CSTOnlineBarButton2

+ (CSTOnlineBarButton2 *)sharedOnlineButton2
{
    static CSTOnlineBarButton2 *sharedOnlineButton2 = nil;
    if (!sharedOnlineButton2)
        sharedOnlineButton2 = [[super allocWithZone:nil] init];
    
    
    return sharedOnlineButton2;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedOnlineButton2];
}

- (id)init
{
    self = [super init];
    if (self) {
        
        [self setBackgroundImage:[UIImage imageNamed:@"online-btn-off.png"] forState:UIControlStateNormal];
        [self setBackgroundImage:[UIImage imageNamed:@"online-btn-on.png"] forState:UIControlStateSelected];
        self.frame=CGRectMake(0.0f, 0.0f, 108.0f, 35.0f);
        self.selected = YES;
        [self setTitle:@"   ONLINE" forState:UIControlStateSelected];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [self setTitle:@"    OFFLINE" forState:UIControlStateNormal];
        [self setTitleColor:[UIColor colorWithRed:164.0/255.0 green:164.0/255.0 blue:164.0/255.0 alpha:1] forState:UIControlStateNormal];
        self.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:12.0f];
        [self.layer setMasksToBounds:YES];
        self.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    
        self.selected = [OfflineDataManager sharedOfflineDataManager].online;
        [OfflineDataManager sharedOfflineDataManager].onlineTrackingBlock = ^(BOOL online) {
            if(self.selected && !online) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Online status" message:@"Internet connection is not available." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                    [alertView show];
                    self.selected = NO;
                    if(self.onlineSwitchTrackingBlock) {
                        self.onlineSwitchTrackingBlock(NO);
                    }
                });
            } else if(self.selected == online) {
                if(self.onlineSwitchTrackingBlock) {
                    self.onlineSwitchTrackingBlock(online);
                }
            }
        };
    }
    [self addTarget:self action:@selector(changeState) forControlEvents:UIControlEventTouchUpInside];

    return self;
}

-(void) changeState {
    self.selected = !self.selected;
    [OfflineDataManager sharedOfflineDataManager].online = self.selected;
//    [Flurry logEvent:@"online_btn_pressed"];
}

@end
