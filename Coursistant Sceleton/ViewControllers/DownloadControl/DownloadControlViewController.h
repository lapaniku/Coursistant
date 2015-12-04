//
//  DownloadControlViewController.h
//  Coursistant Sceleton
//
//  Created by Andrew on 05.06.13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DownloadControlViewController.h"
#import "JSFlatButton.h"

@interface DownloadControlViewController : UIViewController {
    
    NSMutableArray *storedKeys;
}


@property (weak, nonatomic) IBOutlet UILabel *downloadCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *partialCountLabel;


@property (weak, nonatomic) IBOutlet UITextView *partialCommentLabel;

@property (weak, nonatomic) IBOutlet UITextView *downloadCommentLabel;

@property (weak, nonatomic) IBOutlet UIButton *resumeButton;
@property (weak, nonatomic) IBOutlet UITextView *courseTextArea;

@property (nonatomic, copy) void (^pauseBlock) (NSString *key);

@property (nonatomic, copy) void (^resumeBlock) (NSString *key);

@property (nonatomic, copy) void (^resumeFirstTimeBlock) (void);
@property (weak, nonatomic) IBOutlet UIImageView *playImg;

- (IBAction)resume:(id)sender;

- (void) update;

- (void) resetState;

@end
