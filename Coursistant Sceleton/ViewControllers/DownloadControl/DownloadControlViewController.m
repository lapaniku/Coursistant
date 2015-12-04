//
//  DownloadControlViewController.m
//  Coursistant Sceleton
//
//  Created by Andrew on 05.06.13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import "DownloadControlViewController.h"
#import "DownloadManager.h"
#import "ProgressDataManager.h"
#import "Flurry.h"

@interface DownloadControlViewController ()

@end

@implementation DownloadControlViewController

#define POPOVER_WIDTH 297
#define POPOVER_HEIGHT 321

@synthesize downloadCountLabel, partialCountLabel, partialCommentLabel, downloadCommentLabel;
@synthesize pauseBlock, resumeBlock, resumeFirstTimeBlock;
@synthesize resumeButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.view.backgroundColor = [UIColor colorWithRed:61.0/255.0 green:174.0/255.0 blue:211.0/255.0 alpha:1.0];
    //self.view.backgroundColor = [UIColor colorWithRed:37.0/255.0 green:161.0/255.0 blue:83.0/255.0 alpha:1.0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setDownloadCountLabel:nil];
    [self setResumeButton:nil];
    [self setCourseTextArea:nil];
    [self setPartialCountLabel:nil];
    [self setPartialCommentLabel:nil];
    [self setDownloadCommentLabel:nil];
    [self setPlayImg:nil];
    [super viewDidUnload];
}

- (IBAction)resume:(id)sender {
    
//    NSDictionary *downloadControl = [NSDictionary dictionaryWithObjectsAndKeys: downloadCountLabel.text, @"downloadCountLabel",
//                                 partialCountLabel.text, @"partialCountLabel",
//                                 self.courseTextArea.text, @"courseList",
//                                 nil];
//    
//    [Flurry logEvent:@"Download_manager" withParameters:downloadControl];
    
    if(self.resumeButton.selected) {
        [[DownloadManager sharedDownloadManager] pauseAll:pauseBlock];
        [self updateActiveState:NO];
    } else {
        if(storedKeys != nil && [storedKeys count] > 0) {
            if(resumeFirstTimeBlock != nil) {
                resumeFirstTimeBlock();
            }
            [storedKeys removeAllObjects];
            [self update];
        }
        [[DownloadManager sharedDownloadManager] resumeAll:resumeBlock];
        [self updateActiveState:YES];
    }
}

- (void) updateActiveState:(BOOL)active {
    if(!active) {
//        [resumeButton setImage:[UIImage imageNamed:@"resume-all-selected.png"] forState:UIControlStateHighlighted];
//        [resumeButton setImage:[UIImage imageNamed:@"resume-all-unselected.png"] forState:UIControlStateNormal];
        [self.playImg setImage:[UIImage imageNamed:@"play.png"]];
       

        resumeButton.selected = NO;
    } else {
//        [resumeButton setImage:[UIImage imageNamed:@"pause-all-selected.png"] forState:UIControlStateHighlighted];
//        [resumeButton setImage:[UIImage imageNamed:@"pause-all-unselected.png"] forState:UIControlStateSelected];
        [self.playImg setImage:[UIImage imageNamed:@"pause.png"]];
        resumeButton.selected = YES;
    }
}

- (void) update {
    if(storedKeys == nil) {
        storedKeys = [[[ProgressDataManager sharedProgressDataManager] storedKeys] mutableCopy];
    }

    NSInteger storedCount = [storedKeys count];
    if (storedCount < 1) {
        partialCountLabel.text = @"0";
        partialCommentLabel.text = @"partialy downloaded";

    } else if(storedCount == 1) {
        partialCountLabel.text = @"1";
        partialCommentLabel.text = @"partialy downloaded";
    } else {
        partialCountLabel.text = [[NSString alloc] initWithFormat:@"%d", storedCount];
        partialCommentLabel.text = @"partialy downloaded";
    }
    NSInteger currentCount = [[DownloadManager sharedDownloadManager] downloadOperationCount];
    if(currentCount < 1) {
        downloadCountLabel.text = @"0";
        downloadCommentLabel.text = @"now downloading";
    } else if(currentCount == 1) {
        downloadCountLabel.text = @"1";
        downloadCommentLabel.text = @"now downloading";
    } else {
        downloadCountLabel.text = [[NSString alloc] initWithFormat:@"%d", currentCount];
        downloadCommentLabel.text = @"now downloading";
    }
    
    NSMutableSet *courses = [[NSMutableSet alloc] init];
    NSArray *allKeys = [storedKeys arrayByAddingObjectsFromArray:[[DownloadManager sharedDownloadManager] allActiveKeys]];
    for (NSString *key in allKeys) {
        NSString *course = [key stringByDeletingPathExtension];
        [courses addObject:course];
    }
    self.courseTextArea.text = [[[courses allObjects] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSCaseInsensitiveSearch];
    }] componentsJoinedByString:@",\n"];
    
    [self setContentSizeForViewInPopover:CGSizeMake(POPOVER_WIDTH, POPOVER_HEIGHT)];
    
    [self updateActiveState:[[DownloadManager sharedDownloadManager] isAnyOperationActive]];
}

- (void) resetState {
    storedKeys = nil;
}

@end
