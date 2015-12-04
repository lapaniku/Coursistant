//
//  GlobalProgressHUD.m
//  Coursistant Sceleton
//
//  Created by Andrew on 04.03.13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import "GlobalProgressHUD.h"
#import "MBProgressHUD.h"
#import "OperationService.h"

@implementation GlobalProgressHUD


-(id) init {
        
    self = [super init];
    HUDSingleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTap:)];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(catchProgressNotification:) name:@"operationsStarted" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(catchProgressNotification:) name:@"operationsFinished" object:nil];

    return self;
}

-(void) catchProgressNotification:(NSNotification *) notification {
    if([@"operationsStarted" isEqualToString:notification.name]) {
        [self showGlobalProgressHUD:@"Loading.\nTap to cancel."];
    } else if([@"operationsFinished" isEqualToString:notification.name]) {
        [self dismissGlobalHUD];
    }
}

- (MBProgressHUD *)showGlobalProgressHUD:(NSString *)title {
    UIWindow *window = [[[UIApplication sharedApplication] windows] lastObject];
    [MBProgressHUD hideAllHUDsForView:window animated:YES];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:window animated:YES];
    hud.labelText = title;
    [hud addGestureRecognizer:HUDSingleTap];
    return hud;
}

- (void)dismissGlobalHUD {
    UIWindow *window = [[[UIApplication sharedApplication] windows] lastObject];
    [MBProgressHUD hideHUDForView:window animated:YES];
}

- (void)singleTap:(UITapGestureRecognizer*)sender {
    [[OperationService sharedOperationService] cancelAllOperations];
    //NSLog(@"Tapped to cancel");
}

+(void) progressHudOn:(UIView *)view {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    
    hud.labelText = @"loading";
}

+(void) progressHudOff:(UIView *)view {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [MBProgressHUD hideHUDForView:view animated:YES];
}


@end
