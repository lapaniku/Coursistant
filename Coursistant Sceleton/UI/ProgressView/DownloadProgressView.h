//
//  DownloadProgressView.h
//  Coursistant Sceleton
//
//  Created by Andrew on 03.04.13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import "CERoundProgressView.h"

@interface DownloadProgressView : UIView {
    
    UIActionSheet *popup;
}

@property (nonatomic) BOOL downloadedState;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (weak, nonatomic) IBOutlet UIButton *downloadButton;

@property (weak, nonatomic) IBOutlet CERoundProgressView *progressView;

@property (weak, nonatomic) IBOutlet UIImageView *coverImage;


- (void) setDownloadedState:(BOOL)downloadState;

- (void) startPreparation;

- (void) stopPreparation;

- (void) setEnabled:(BOOL)enabled;

@end
