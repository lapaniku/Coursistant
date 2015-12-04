//
//  LectureSpeedViewController.m
//  Coursistant
//
//  Created by Andrew on 09.10.13.
//  Copyright (c) 2013 Altasapiens. All rights reserved.
//

#import "LectureSpeedViewController.h"

@interface LectureSpeedViewController ()

@end

@implementation LectureSpeedViewController

@synthesize speed;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        speed = 1.0f;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:61.0/255.0 green:174.0/255.0 blue:211.0/255.0 alpha:1.0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)speedChanged:(UISlider *)sender {
    speed = [sender value];
    if ( speed < 1.05 && speed > 0.95) {
        speed = 1;
    }
    if(self.speedTrackingBlock) {
        self.speedTrackingBlock(speed);
    }
}


@end
