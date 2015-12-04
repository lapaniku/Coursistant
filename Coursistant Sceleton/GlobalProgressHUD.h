//
//  GlobalProgressHUD.h
//  Coursistant Sceleton
//
//  Created by Andrew on 04.03.13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"

@interface GlobalProgressHUD : NSObject {
    
    UITapGestureRecognizer *HUDSingleTap;
}

+(void) progressHudOn:(UIView *)view;

+(void) progressHudOff:(UIView *)view;

@end
