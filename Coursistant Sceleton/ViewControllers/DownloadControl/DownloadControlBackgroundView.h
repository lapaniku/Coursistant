//
//  DownloadControlBackgroundView.h
//  Coursistant Sceleton
//
//  Created by Andrew on 31.07.13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DownloadControlBackgroundView : UIPopoverBackgroundView {
    
    UIImageView *_borderImageView;
    UIImageView *_arrowView;
    CGFloat _arrowOffset;
    UIPopoverArrowDirection _arrowDirection;
}

@end
