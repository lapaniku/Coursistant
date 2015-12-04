//
//  CSTDownloadControlButton.m
//  Coursistant Sceleton
//
//  Created by Andrew on 04.06.13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import "CSTDownloadControlButton.h"
#import "DownloadControlViewController.h"
#import "DownloadControlBackgroundView.h"
#import "DownloadManager.h"
#import "ProgressDataManager.h"
#import "Flurry.h"

@implementation CSTDownloadControlButton
@synthesize wasBgDownloadPaused;

CWL_SYNTHESIZE_SINGLETON_FOR_CLASS(CSTDownloadControlButton);

- (id)init
{
    self = [super init];
    if (self) {
        [self setDownloadActive:NO];

        self.frame=CGRectMake(0.0, 0.0, 28.0, 28.0);

        [self addTarget:self action:@selector(openPopOver) forControlEvents:UIControlEventTouchUpInside];
        
        downloadControlViewController = [[DownloadControlViewController alloc] initWithNibName:@"DownloadControlViewController" bundle:nil];
        popover = [[UIPopoverController alloc] initWithContentViewController:downloadControlViewController];
        popover.popoverBackgroundViewClass = [DownloadControlBackgroundView class];
        
        isFirstTime = true;
        wasBgDownloadPaused = NO;
        isActiveFlag = NO;
    }
    
    return self;
}

- (void) setDownloadActive:(BOOL)isActive {
    if(isActive) {
        [self setBackgroundImage:[UIImage imageNamed:@"downloads-active2.png"] forState:UIControlStateNormal];
        [self setBackgroundImage:[UIImage imageNamed:@"downloads-active2.png"] forState:UIControlStateSelected];
    } else {
        [self setBackgroundImage:[UIImage imageNamed:@"downloads-inactive2.png"] forState:UIControlStateNormal];
        [self setBackgroundImage:[UIImage imageNamed:@"downloads-inactive2.png"] forState:UIControlStateSelected];
        [popover dismissPopoverAnimated:NO];
    }
    isActiveFlag = isActive;
    //[self setUserInteractionEnabled:isActive];
}

- (void) openPopOver {
    if (isActiveFlag) {
        //    [downloadControlViewController update];
        popover.popoverContentSize = downloadControlViewController.contentSizeForViewInPopover;
        [popover presentPopoverFromRect:self.frame inView:self.superview permittedArrowDirections:UIPopoverArrowDirectionUp animated:NO];
    }
//    [Flurry logEvent:@"openPopOver_download_mng"];

}

- (DownloadControlViewController *) downloadControlViewController {
    return downloadControlViewController;
}

- (void) update {
    NSInteger downloadCount = [[DownloadManager sharedDownloadManager] downloadOperationCount] + [[[ProgressDataManager sharedProgressDataManager] storedKeys] count];
    [self setDownloadActive:(downloadCount > 0)];
    [downloadControlViewController update];
}

- (void) resetState {
    [downloadControlViewController resetState];
    [self update];
}

@end
