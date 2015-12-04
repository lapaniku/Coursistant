//
//  LectureSpeedViewController.h
//  Coursistant
//
//  Created by Andrew on 09.10.13.
//  Copyright (c) 2013 Altasapiens. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LectureSpeedViewController : UIViewController

@property (nonatomic, copy) void (^speedTrackingBlock)(float speed);
@property (nonatomic) float speed;

- (IBAction)speedChanged:(UISlider *)sender;

@end
