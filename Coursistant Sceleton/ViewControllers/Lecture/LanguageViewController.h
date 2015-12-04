//
//  LanguageViewController.h
//  Coursistant
//
//  Created by Andrei Lapanik on 07.02.14.
//  Copyright (c) 2014 Altasapiens. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DownloadItem.h"
#import "DelegateStack.h"
#import "JSFlatButton.h"

@interface LanguageViewController : UIViewController <UITableViewDelegate> {
    
    NSMutableArray *tableItems;
    NSMutableDictionary *languageIndex;
    NSMutableArray *subtitleFiles;
    DelegateStack *delegateStack;
    BOOL allLanguages;
}

@property (weak, nonatomic) UIPopoverController *popover;

@property (weak, nonatomic) NSArray *subtitles;

@property (weak, nonatomic) DownloadItem *downloadItem;

@property (nonatomic, copy) void (^languageTrackingBlock)(NSString *languageCode, NSString *languageFile);

@property (weak, nonatomic) IBOutlet UITableView *languageTable;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity;

@property (weak, nonatomic) IBOutlet UILabel *viewCaptionLabel;

- (IBAction)buySubtitles;

@property (weak, nonatomic) IBOutlet JSFlatButton *buyButton;

@property (weak, nonatomic) IBOutlet JSFlatButton *restoreButton;

- (IBAction)restorePurchase;

@end
