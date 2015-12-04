//
//  CSTAddNewCourseCell.m
//  Coursistant
//
//  Created by Администратор on 28.11.13.
//  Copyright (c) 2013 Altasapiens. All rights reserved.
//

#import "CSTAddNewCourseCell.h"
#import "Flurry.h"

@implementation CSTAddNewCourseCell


@synthesize webViewController, parentVC;
@synthesize addNewUdacityBtn, addNewCourseraBtn;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code


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

- (void)awakeFromNib {
    [super awakeFromNib];
    [addNewCourseraBtn setButtonBackgroundColor:[UIColor colorWithRed:59.0f/255.0f green:110.0f/255.0f blue:143.0f/255.0f alpha:1.0f]];
    [addNewUdacityBtn setButtonBackgroundColor:[UIColor colorWithRed:240.0f/255.0f green:118.0f/255.0f blue:33.0f/255.0f alpha:1.0f]];
    
}


- (IBAction)addNewCoursera:(id)sender {
    
    [parentVC closeLeftBar];
    if (webViewController == nil){
        webViewController = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil];
    }
    NSString *signUpLink = @"https://www.coursera.org/courses";
    [webViewController navigationItem].title = signUpLink;
    webViewController.resourceURL = [NSURL URLWithString:signUpLink];
    [parentVC.navigationController pushViewController:webViewController animated:YES];
    NSDictionary *eventParam = [NSDictionary dictionaryWithObjectsAndKeys: @"Coursera", @"provider", nil];
    [Flurry logEvent:@"addNewCoursePressed" withParameters:eventParam];
}

- (IBAction)addNewUdacity:(id)sender {
    [parentVC closeLeftBar];
    if (webViewController == nil){
        webViewController = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil];
    }
    NSString *signUpLink = @"https://www.udacity.com/courses";
    [webViewController navigationItem].title = signUpLink;
    webViewController.resourceURL = [NSURL URLWithString:signUpLink];
    [parentVC.navigationController pushViewController:webViewController animated:YES];
    NSDictionary *eventParam = [NSDictionary dictionaryWithObjectsAndKeys: @"Udacity", @"provider", nil];
    [Flurry logEvent:@"addNewCoursePressed" withParameters:eventParam];
}
@end
