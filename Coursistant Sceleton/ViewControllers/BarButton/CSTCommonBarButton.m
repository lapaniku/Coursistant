//
//  CSTCommonBarButton.m
//  Coursistant
//
//  Created by Andrew on 08.10.13.
//  Copyright (c) 2013 Altasapiens. All rights reserved.
//

#import "CSTCommonBarButton.h"
#import <QuartzCore/QuartzCore.h>

@implementation CSTCommonBarButton

- (id)initWithNormalTitle:(NSString*)normalTitle andSelectedTitle:(NSString*)selectedTitle
{
    self = [super init];
    if (self) {
        
        [self setTitle:selectedTitle forState:UIControlStateSelected];
        [self setTitle:normalTitle forState:UIControlStateNormal];
        [self setBackgroundImage:[UIImage imageNamed:@"right-nav-btn-off.png"] forState:UIControlStateNormal];
        [self setBackgroundImage:[UIImage imageNamed:@"right-nav-btn-on.png"] forState:UIControlStateSelected];
        self.frame=CGRectMake(0.0f, 0.0f, 108.0f, 35.0f);
        self.selected = YES;
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [self setTitleColor:[UIColor colorWithRed:164.0/255.0 green:164.0/255.0 blue:164.0/255.0 alpha:1] forState:UIControlStateNormal];
        self.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:12.0f];
        [self.layer setMasksToBounds:YES];
        self.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        [self addTarget:self action:@selector(changeState) forControlEvents:UIControlEventTouchUpInside];        
    }
    
    return self;
}

-(void) changeState {
    self.selected = !self.selected;
    if(self.stateTrackingBlock) {
        self.stateTrackingBlock(self.selected);
    }

}


@end
