//
//  CSTAddNewCourseCell.h
//  Coursistant
//
//  Created by Администратор on 28.11.13.
//  Copyright (c) 2013 Altasapiens. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSTCollectionView.h"
#import "JSFlatButton.h"
#import "WebViewController.h"
#import "CSTDetailViewController.h"


@interface CSTAddNewCourseCell : PSUICollectionViewCell
@property (weak, nonatomic) IBOutlet JSFlatButton *addNewCourseraBtn;
@property (weak, nonatomic) IBOutlet JSFlatButton *addNewUdacityBtn;
- (IBAction)addNewCoursera:(id)sender;
- (IBAction)addNewUdacity:(id)sender;

@property (strong, nonatomic) WebViewController *webViewController;

@property (weak, nonatomic) CSTDetailViewController *parentVC;


@end
