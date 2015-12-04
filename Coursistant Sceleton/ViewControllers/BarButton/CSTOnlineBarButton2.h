//
//  CSTOnlineBarButton2.h
//  Coursistant Sceleton
//
//  Created by Администратор on 10.5.13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CSTOnlineBarButton2 : UIButton
+ (CSTOnlineBarButton2 *)sharedOnlineButton2;

@property (nonatomic, copy) void (^onlineSwitchTrackingBlock)(BOOL online);

@end
