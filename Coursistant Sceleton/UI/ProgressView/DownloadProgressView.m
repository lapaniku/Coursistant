//
//  DownloadProgressView.m
//  Coursistant Sceleton
//
//  Created by Andrew on 03.04.13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import "DownloadProgressView.h"

@implementation DownloadProgressView

@synthesize activityIndicator;
@synthesize downloadButton;
@synthesize progressView;
@synthesize downloadedState = _downloadedState;
@synthesize coverImage;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder*)coder
{
    if ((self = [super initWithCoder:coder])) {
        [self commonInit];
    }
    return self;
}

- (void) awakeFromNib {
    [self commonInit];
}

- (void) commonInit {
    
    self.progressView.startAngle = (3.0*M_PI)/2.0;
//    self.progressView.trackColor = [UIColor colorWithRed:152 green:182 blue:62 alpha:0];
//    self.progressView.tintColor = [UIColor colorWithRed:152 green:182 blue:62 alpha:0];
    self.backgroundColor = [UIColor clearColor];
    
    UIColor *progressColor = [UIColor colorWithRed:152.0f/255.0f green:182.0f/255.0f blue:62.0f/255.0f alpha:1.0f];
    [[CERoundProgressView appearance] setTintColor:progressColor];
    
    self.progressView.trackColor = [UIColor whiteColor];
}

- (void) setDownloadedState:(BOOL)downloadState {
    
    _downloadedState = downloadState;
    if(_downloadedState) {
        self.progressView.progress = 0;
        
        [downloadButton setImage:[UIImage imageNamed:@"downloaded.png"] forState:UIControlStateNormal];
        [downloadButton setImage:[UIImage imageNamed:@"downloaded.png"] forState:UIControlStateSelected];
    } else {
        [downloadButton setImage:[UIImage imageNamed:@"download.png"] forState:UIControlStateNormal];
        [downloadButton setImage:[UIImage imageNamed:@"downloading.png"] forState:UIControlStateSelected];
        downloadButton.selected = NO;
    }
}

- (void) startPreparation {
    downloadButton.hidden = YES;
    progressView.hidden = YES;
    activityIndicator.hidden = NO;
    [activityIndicator startAnimating];
}

- (void) stopPreparation {
    progressView.hidden = NO;
    downloadButton.hidden = NO;
    [activityIndicator stopAnimating];
    activityIndicator.hidden = YES;
}

- (void) setEnabled:(BOOL)enabled {
    super.userInteractionEnabled = enabled;
    //[[super view] setEnabled:enabled];
    if(enabled) {
        coverImage.backgroundColor = [UIColor clearColor];
        coverImage.userInteractionEnabled = NO;
    } else {
        coverImage.backgroundColor = [UIColor colorWithWhite:0.667 alpha:0.7]; // lightGray with alfa
        coverImage.userInteractionEnabled = YES;
    }
}

@end
