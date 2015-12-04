//
//  CSTDownloadControlButton.h
//  Coursistant Sceleton
//
//  Created by Andrew on 04.06.13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CWLSynthesizeSingleton.h"
#import "DownloadControlViewController.h"

@interface CSTDownloadControlButton : UIButton {
    
    DownloadControlViewController *downloadControlViewController;
    UIPopoverController *popover;
    BOOL isFirstTime;
    BOOL isActiveFlag;

}

CWL_DECLARE_SINGLETON_FOR_CLASS(CSTDownloadControlButton)

@property BOOL wasBgDownloadPaused;
- (DownloadControlViewController *) downloadControlViewController;

- (void) setDownloadActive:(BOOL)isActive;
- (void) openPopOver;

- (void) update;

- (void) resetState;

@end
