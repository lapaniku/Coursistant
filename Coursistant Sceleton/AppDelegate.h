//
//  AppDelegate.h
//  Coursistant Sceleton
//
//  Created by Andrew on 19.12.12.
//  Copyright (c) 2012 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSTLoginViewController.h"
#import "CSTDetailViewController.h"
#import "CSTSettingsViewController.h"
#import "IIViewDeckController.h"
#import "CSTSideViewController.h"

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    
//    GlobalProgressHUD *hud;
};


@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) ViewController *viewController;

@property (strong, nonatomic) UINavigationController *navigationController;
//@property (strong, nonatomic) CSTLoginViewController *loginViewController;
//@property (strong, nonatomic) CSTDetailViewController *detailViewController;
//@property (strong, nonatomic) CSTSideViewController *leftController;
//@property (strong, nonatomic) IIViewDeckController* deckController;

-(void) customizeAppearance;

@end
