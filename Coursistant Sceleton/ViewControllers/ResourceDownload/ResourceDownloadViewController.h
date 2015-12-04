//
//  ResourceDownloadViewController.h
//  Coursistant
//
//  Created by Andrei Lapanik on 22.10.13.
//  Copyright (c) 2013 Altasapiens. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebViewController.h"
#import "DownloadItem.h"
#import "DelegateStack.h"
#import "JSFlatButton.h"
@class CSTWeekViewController;

@interface ResourceDownloadViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIDocumentInteractionControllerDelegate> {
    
    DelegateStack *delegateStack;
    NSMutableDictionary *accessoryViews;
    BOOL allDownloadedState;
//    UILabel *wordLabel;
}

@property (weak, nonatomic) NSArray *resources;

@property DownloadItem *lectureDownloadItem;

@property (weak, nonatomic) IBOutlet UITableView *resourceTable;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *downloadActivity;

@property (weak, nonatomic) IBOutlet JSFlatButton *downloadRemoveBtn3;

////////
@property (nonatomic, strong)UIDocumentInteractionController *docInteractionController;

//@property (strong, nonatomic)  CSTWeekViewController *weekViewController;
@property (weak, nonatomic) CSTWeekViewController *weekViewController;

@property (weak, nonatomic) UIPopoverController *popover;

- (IBAction)downloadRemoveBtnPressed:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *resourseCountLbl;
@property (strong, nonatomic) WebViewController *webViewController;

@end
