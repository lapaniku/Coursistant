//
//  CSTActivityViewForButton.m
//  Coursistant Sceleton
//
//  Created by Andrew on 26.05.13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import "CSTUIHelper.h"

@implementation CSTUIHelper

+ (void) addActivityView:(UIButton *)button {
    UIActivityIndicatorView* spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    CGRect spinnerFrame = spinner.frame;
    if (button.frame.size.width < spinnerFrame.size.width + button.bounds.size.height / 2) {
        spinnerFrame = button.bounds;
    } else {
        spinnerFrame.origin = CGPointMake( - spinnerFrame.size.width*1.5/*button.bounds.size.height/2 - spinnerFrame.size.width/2*/, button.bounds.size.height/2 - spinnerFrame.size.height/2);
    }
    spinner.frame = spinnerFrame;
    [button addSubview:spinner];
    [spinner startAnimating];
}

+ (void) removeActivityView:(UIButton *)button {
    for (UIView* v in button.subviews) {
        if ([v isKindOfClass:[UIActivityIndicatorView class]]) {
            [(UIActivityIndicatorView*)v stopAnimating];
            [v removeFromSuperview];
        }
    }
}

+ (void) showInstantError:(NSError *)error targetView:(UIView *)targetView {
    NSDictionary *userInfo = [error userInfo];
    NSString *errorMessage = [[userInfo objectForKey:NSUnderlyingErrorKey] localizedDescription];
    
    NSString *message = [NSString stringWithFormat:@"Error occured:\n%@", errorMessage];
    [CSTUIHelper showInstantMessage:message targetView:targetView];
}

+ (void) showInstantMessage:(NSString *)message targetView:(UIView *)targetView {
    UIActionSheet *popup = [[UIActionSheet alloc]
                            initWithTitle:message
                            delegate:nil cancelButtonTitle:@"Cancel"
                            destructiveButtonTitle:nil otherButtonTitles: nil];
    
    [popup sizeToFit];
    popup.tag = 9999;
    
    if(targetView.window != nil) {
        [popup showFromRect:targetView.frame inView:targetView.superview animated:YES];
    }
    
    [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(hideInstantMessage:) userInfo:popup repeats:NO];
}

+ (void) hideInstantMessage:(NSTimer *)timer
{
    UIActionSheet *popup = timer.userInfo;
    [popup dismissWithClickedButtonIndex:0 animated:YES];
}

@end
