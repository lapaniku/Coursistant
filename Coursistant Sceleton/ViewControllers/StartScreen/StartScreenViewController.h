//
//  StartScreenViewController.h
//  Coursistant Sceleton
//
//  Created by Andrew on 12.04.13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSTDetailViewController.h"
#import "CSTLoginViewController.h"
#import "ILoginDelegate.h"
#import "IParserDelegate.h"
#import "DelegateStack.h"
#import <MessageUI/MessageUI.h>


@interface StartScreenViewController : UIViewController <ILoginDelegate, IParserDelegate, MFMailComposeViewControllerDelegate> {
    
    id<ILoginManager> courseraLoginManager;
    id<ILoginManager> udacityLoginManager;
    DelegateStack *delegateStack;
    BOOL errorDisplayed;
}

@property (nonatomic, weak) CSTDetailViewController *detailViewController;

@property (nonatomic, strong) CSTLoginViewController *loginViewController;

@property (weak, nonatomic) IBOutlet UILabel *courseraLabel;

@property (weak, nonatomic) IBOutlet UILabel *udacityLabel;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *courseraActivity;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *udacityActivity;
@property (weak, nonatomic) IBOutlet UIImageView *waveImage;
@property (weak, nonatomic) IBOutlet UIImageView *bgImage;
@property (weak, nonatomic) NSTimer *repeatingTimer;
@property (weak, nonatomic) IBOutlet UILabel *versionLb;
@property (weak, nonatomic) IBOutlet UIImageView *liteBg;
@property (weak, nonatomic) IBOutlet UILabel *liteLb;


@end
