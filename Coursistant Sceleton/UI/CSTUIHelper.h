//
//  CSTActivityViewForButton.h
//  Coursistant Sceleton
//
//  Created by Andrew on 26.05.13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CSTUIHelper : NSObject 

+ (void) addActivityView:(UIButton *)button;

+ (void) removeActivityView:(UIButton *)button;

+ (void) showInstantError:(NSError *)error targetView:(UIView *)targetView;

+ (void) showInstantMessage:(NSString *)message targetView:(UIView *)targetView;

@end
