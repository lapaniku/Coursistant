//
//  CSTCommonBarButton.h
//  Coursistant
//
//  Created by Andrew on 08.10.13.
//  Copyright (c) 2013 Altasapiens. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CSTCommonBarButton : UIButton

- (id)initWithNormalTitle:(NSString*)normalTitle andSelectedTitle:(NSString*)selectedTitle;

@property (nonatomic, copy) void (^stateTrackingBlock)(BOOL state);

@end
