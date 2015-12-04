//
//  SubtitleView.m
//  Coursistant
//
//  Created by Andrew on 01.10.13.
//  Copyright (c) 2013 Altasapiens. All rights reserved.
//

#import "SubtitleView.h"

@implementation SubtitleView

- (id)init
{
    self = [super init];
    if (self) {
        [self configure];
    }
    return self;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configure];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void) addToViewController:(UIViewController*)viewController
{    
    [self removeFromSuperview];
    CGRect frame = self.frame;
    frame.size = CGSizeMake(viewController.view.bounds.size.width, viewController.view.bounds.size.height / 8);
    NSUInteger delta = viewController.view.bounds.size.height / 12;

    frame.origin = CGPointMake(0, viewController.view.bounds.size.height-frame.size.height-delta);
    self.frame = frame;
    [viewController.view addSubview:self];
}

-(void) addToVideoView
{
    UIWindow *window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    UIView * videoView = [[window subviews] lastObject];
    
    [self removeFromSuperview];
    CGRect frame = self.frame;
    frame.size = CGSizeMake(videoView.bounds.size.width, videoView.bounds.size.height / 8);
    frame.origin = CGPointMake(0, videoView.bounds.size.height-frame.size.height);
    self.frame = frame;
    [videoView addSubview:self];
}

-(void) configure {
    self.userInteractionEnabled = NO;
    self.textColor = [UIColor yellowColor];
    self.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
    self.font = [UIFont fontWithName:@"Helvetica-Bold" size:28.0f];
    self.textAlignment = NSTextAlignmentCenter;
}


@end
