//
//  CSTWeekViewController.m
//  Coursistant05
//
//  Created by Администратор on 7.3.13.
//  Copyright (c) 2013 Администратор. All rights reserved.
//

#import "CSTWeekViewController.h"
//#import "CSTCourse.h"

#import "UIImageView+WebCache.h"
#import "CollectionUtils.h"
//#import "UIImage+iPhone5.h"

#import <MediaPlayer/MediaPlayer.h>
#import "GlobalConst.h"

//coursera
#import "DownloadManager.h"
#import "DACircularProgressView.h"
#import "MBProgressHUD.h"
#import "DownloadItem.h"
#import "CourseraProviderService.h"
//edx
#import "BasicContentManager.h"


#import "DownloadProgressView.h"

#import "CSTDownloadControlButton.h"
#import "CSTOnlineBarButton2.h"
#import "JSFlatButton.h"
#import "JSQFlatButton.h"

//online/offline status
#import "OfflineDataManager.h"

#import <CoreText/CoreText.h>
#import "AlertViewBlocks.h"

#import "CSTUIHelper.h"


#import "CSTWeekTableViewCellCategory.h"
#import "CSTWeekTableViewCellVideo.h"
#import "DownloadControlBackgroundView.h"
#import "PopoverCommonBackground.h"
#import "DownloadItemHelper.h"

#import "Flurry.h"
#import "ToastView.h"
#import "LinkProcessingDelegate.h"
#import "SettingsHelper.h"
#import "CoursistantIAPHelper.h"
#import <EXTScope.h>


@interface CSTWeekViewController (){
    int videoIdSelectedForPlay;
    int lastSelectedVideoIndex;
    
}


@end

@implementation CSTWeekViewController

//@synthesize courseObj;
@synthesize lectureViewController;

//weeks array
@synthesize weeks;
//
//
@synthesize selectedCourse, providerName;
//
//edx
@synthesize service;
//
// BANNER REMOVING
//@synthesize adBanner;

@synthesize switchArchivedRound;
@synthesize progressBarWeek;
@synthesize webViewController;


//@synthesize downloadAllButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self configureGlobalDownloadView];
        [self initDownloadControlContainers];
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    videoIdSelectedForPlay = 0;

    
    
    UIColor* bgColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"backgroundVC.png"]];
    [self.view setBackgroundColor:bgColor];
    [self.tableWeek setBackgroundColor:bgColor];
    
    videoProcessingManager = [[CourseraProviderService sharedCourseraProviderService] lectureManager:[[LinkProcessingDelegate alloc] init]];
    
    subtitleProcessingManager = [[CourseraProviderService sharedCourseraProviderService] lectureManager:[[LinkProcessingDelegate alloc] init]];
    
    self.lectureViewController = [[LectureViewController alloc] init];
    youtubeURLManager = [[YouTubeURLManager alloc] init];
    
    //////left bar button
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 39, 29)];
    [backButton setImage:[UIImage imageNamed:@"back-btn.png"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    
    BOOL aboveIOS61 = kCFCoreFoundationVersionNumber > kCFCoreFoundationVersionNumber_iOS_6_1;
    if (aboveIOS61) {
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                           initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                           target:nil action:nil];
        negativeSpacer.width = -10;
        UIBarButtonItem *sideButtonBar = [[UIBarButtonItem alloc] initWithCustomView:backButton];
        [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:negativeSpacer, sideButtonBar, nil] animated:NO];
    } else
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    //////right bar button
    UIBarButtonItem* onlineButton = [[UIBarButtonItem alloc] initWithCustomView:[CSTOnlineBarButton2 sharedOnlineButton2] ];
    UIBarButtonItem* downloadButton = [[UIBarButtonItem alloc] initWithCustomView:[CSTDownloadControlButton sharedCSTDownloadControlButton] ];
    if (aboveIOS61) {
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                           initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                           target:nil action:nil];
        negativeSpacer.width = -10;
        
        [self.navigationItem setRightBarButtonItems:@[negativeSpacer, onlineButton, downloadButton] animated:NO];
    } else
        self.navigationItem.rightBarButtonItems = @[onlineButton, downloadButton];
    
    /////load completed buttons
    completedButtons = [[NSMutableDictionary alloc] init];
    completedButtonStates = [[NSMutableDictionary alloc] init];
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"completedButtonStates"];
    if (data != nil) {
        NSDictionary *extractedDic = [NSKeyedUnarchiver unarchiveObjectWithData:data] ;
        
        completedButtonStates = [extractedDic mutableCopy];
    }

    /////setup switch archived
    [self.switchArchivedRound addTarget:self action:@selector(switchArchivedChanged:) forControlEvents:UIControlEventValueChanged];
    self.switchArchivedRound.onTintColor = [UIColor colorWithRed:156.0/255.0 green:186.0/255.0 blue:63.0/255.0 alpha:1];
    /////

    
    /////progress bar
    UIImage * backgroundImage = [[UIImage imageNamed:@"progressbar-week-bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 10, 0, 10)];
    UIImage * foregroundImage = [[UIImage imageNamed:@"progressbar-week-fg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, -10, 0, 10)];
    progressBarWeek= [[MCProgressBarView alloc] initWithFrame:CGRectMake(700, 133, 113, 9)
                                                backgroundImage:backgroundImage
                                                foregroundImage:foregroundImage];
    [self.view addSubview:progressBarWeek];
    progressBarWeek.progress = 0.0;
    
    
    [self configureResourcePopover];
    //    resourcePopover.delegate = self;
    
    ///// fix for navbar hiding view in ios7
    self.navigationController.navigationBar.translucent = NO;
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    /////
    


}

-(void)goBack{
    [[self navigationController] popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    if ([self isViewLoaded] && [self.view window] == nil) {
        
        self.view = nil;
        [self viewDidUnload];
        
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    if (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        return NO;
    }
    return YES;
}

-(void)viewWillAppear:(BOOL)animated {
        
    [super viewWillAppear:animated];
    
    NSString *lastVideoKey = [@"videoIndex-" stringByAppendingString:[self getUserDefaultsLectureKey]];
    lastSelectedVideoIndex = [[NSUserDefaults standardUserDefaults] integerForKey:lastVideoKey];

    [[self navigationItem] setTitle:[selectedCourse valueForKey:@"title"]];
    providerName = [selectedCourse valueForKey:@"provider"];
    /////set bg color for weekVC
    switch (self.currentScienceBranchNum) {
        case 1:
            [self.backgroundFill setBackgroundColor: [UIColor colorWithRed:54.0/255.0 green:151.0/255.0 blue:175.0/255.0 alpha:1]];
            self.angleCut.image = [UIImage imageNamed:@"course-img-angle-blue.png"];
            self.courseBranchName = @"Natural";
            break;
        case 2:
            [self.backgroundFill setBackgroundColor: [UIColor colorWithRed:143.0/255.0 green:175.0/255.0 blue:54.0/255.0 alpha:1]];
            self.angleCut.image = [UIImage imageNamed:@"course-img-angle-green.png"];
            self.courseBranchName = @"Social";
            break;
        case 3:
            [self.backgroundFill setBackgroundColor: [UIColor colorWithRed:175.0/255.0 green:65.0/255.0 blue:54.0/255.0 alpha:1]];
            self.angleCut.image = [UIImage imageNamed:@"course-img-angle-red.png"];
            self.courseBranchName = @"Formal";
            break;
        case 4:
            [self.backgroundFill setBackgroundColor: [UIColor colorWithRed:45.0/255.0 green:45.0/255.0 blue:45.0/255.0 alpha:1]];
            self.angleCut.image = [UIImage imageNamed:@"course-img-angle-black.png"];
            self.courseBranchName = @"Applied";
            break;
            
        default:
            [self.backgroundFill setBackgroundColor: [UIColor colorWithRed:114.0/255.0 green:30.0/255.0 blue:80.0/255.0 alpha:1]];
            self.angleCut.image = [UIImage imageNamed:@"course-img-angle-magenta.png"];
            self.courseBranchName = @"Other";
            break;
    }
    
    /////
    

    /////count of completed courses
    numberOfCompletedCourses = 0;
    for (NSString* key in completedButtonStates) {
        
        if ([key rangeOfString:[self baseKey]].location!=NSNotFound) {
            NSNumber *buttonState = [completedButtonStates objectForKey:key];
            if ([buttonState boolValue]) {
                numberOfCompletedCourses++;
            }
        }

    }
    /////
    

    [self updateCourseInfo];

    /////display message when in offline mode there is no stored list of courses
    if([weeks count] == 0) {
        if ([CSTOnlineBarButton2 sharedOnlineButton2].selected) {
            if ([providerName isEqualToString:@"Coursera"]) {
                self.noSavedLecturesTxt.text = @"There is no list of lectures yet. Possible reasons:\n\n1. Coursera Honor Code was not accepted for the course. Please press Open in Web View button and accept the Honor Code\n2. Low connection, servers are busy, network timeout - please try to reenter the course in the app\n3. Course, have finished and is closed at Coursera and thus its structure was never parsed and saved by Coursistant app (otherwise you could see the saved list of lectures\n4. Coursera parser error - please send us feedback via side menu";
                
            } else {
                self.noSavedLecturesTxt.text = @"There is no list of lectures yet. Possible reasons:\n\n1. Low connection, servers are busy, network timeout - please try to reenter the course in the app\n2. Udacity parser error - please send us feedback via side menu";
                
            }
        } else {
            if ([providerName isEqualToString:@"Coursera"]) {
                self.noSavedLecturesTxt.text = @"There is no list of lectures yet. Possible reasons:\n\n1. Course was never opened while onile, and its structure was not saved. Please return to course while online first, and then you can browse it in offline mode";
                
            } else {
                self.noSavedLecturesTxt.text = @"There is no list of lectures yet. Possible reasons:\n\n1. Course was never opened while onile, and its structure was not saved. Please return to course while online first, and then you can browse it in offline mode";
                
            }
            
        }
        
        [self.noSavedLecturesTxt setHidden:NO];
        
    } else if(![self isDownloadLinksAvailable]) {
        self.noSavedLecturesTxt.text = @"Unfortunately, this course contains no links for video download. This could happen due to video distribution restrictions (see course description) or some specific way of video downloding in this course. To access videos online, please use OPEN WEB VIEW button, and let us know about this fact using sidebar feedback.";
        [self.noSavedLecturesTxt setHidden:NO];
        
    } else {
        [self.noSavedLecturesTxt setHidden:YES];
    }
    /////
    
    /////load Arvhived switch state
    NSString *archivedKey;
    if ([[[selectedCourse valueForKey:@"provider"]description] isEqualToString:@"Coursera"]) {
        archivedKey = [[NSString alloc] initWithFormat:@"%@-%@-%@",[[selectedCourse valueForKey:@"provider"]description],[[selectedCourse valueForKey:@"title"]description],[[[selectedCourse valueForKey:@"start_date"]description]substringToIndex:10]];
    } else {
        archivedKey = [[NSString alloc] initWithFormat:@"%@-%@",[[selectedCourse valueForKey:@"provider"]description],[[selectedCourse valueForKey:@"title"]description]];
        
    }
    BOOL state= [[NSUserDefaults standardUserDefaults] boolForKey:archivedKey];
    ///// 2 times below are required - strange bug
    [self.switchArchivedRound setOn:state animated:NO];
    [self.switchArchivedRound setOn:state animated:NO];


    
    //check if archived can be swtiched off
    NSString *actual = [[NSString alloc] initWithFormat:@"%@",[[selectedCourse valueForKey:@"actual"] description]];

    // if online state is changed, table view should be reloaded
    [CSTOnlineBarButton2 sharedOnlineButton2].onlineSwitchTrackingBlock = ^(BOOL online) {
        [self.tableWeek reloadData];
        if(!online) {
            [self.courseWebBtn setEnabled:NO];
            [self.courseWebBtn setBackgroundColor:[UIColor lightGrayColor]];
            [[DownloadManager sharedDownloadManager] pauseAll:^(NSString *key) {
                DownloadProgressView *dpv = [downloadButtons valueForKey:key];
                if(dpv != nil) {
                    dpv.downloadButton.selected = NO;
                }
            }];
        } else {
            [self.courseWebBtn setEnabled:YES];
            [self.courseWebBtn setBackgroundColor:[UIColor colorWithRed:61.0/255.0 green:174.0/255.0 blue:211.0/255.0 alpha:1.0]];
        }
        
    };
    
    if ([actual isEqualToString: @"0"]) {
        [self.switchArchivedRound setEnabled:NO];
        [self.switchArchivedRound setOnTintColor:[UIColor lightGrayColor]];
    } else{
        [self.switchArchivedRound setEnabled:YES];
        self.switchArchivedRound.onTintColor = [UIColor colorWithRed:156.0/255.0 green:186.0/255.0 blue:63.0/255.0 alpha:1];
    }
    
    /////

    
    /////mark last selected video
    
    int numberOfLectures = expandedWeeks.count;
    if (lastSelectedVideoIndex != 0 && [weeks count] != 0 && lastSelectedVideoIndex<=numberOfLectures) {
        NSIndexPath *selectedIndex = [NSIndexPath indexPathForRow:lastSelectedVideoIndex inSection:0];
        //if ([self.tableWeek cellForRowAtIndexPath:selectedIndex]) {
        [self.tableWeek selectRowAtIndexPath:selectedIndex animated:NO scrollPosition:UITableViewScrollPositionMiddle];
        //}
    }
    /////

    ///scroll to last watched video
//    if (lastSelectedVideoIndex != 0){
//    
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:lastSelectedVideoIndex inSection:0];
//    
//    [self.tableWeek scrollToRowAtIndexPath:indexPath
//                          atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
//    
//    }
    ///



}


-(void)viewWillDisappear:(BOOL)animated{
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:completedButtonStates];
    [self saveLastViewedVideo:lastSelectedVideoIndex];
    lastSelectedVideoIndex = 0;
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"completedButtonStates"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[ProgressDataManager sharedProgressDataManager] saveProgressData];
    
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload {
  
    
    [self setCourseDescNuberCoursesLbl:nil];
    //    [self setDownloadAllButton:nil];
    [self setCourseDescLb2:nil];
    [self setCourseProviderLb:nil];
    [self setCourseUniverLb:nil];
    [self setCourseProviderLb:nil];
    [self setCourseProviderBG:nil];
    [self setSwitchArchivedRound:nil];
    [self setProgressBarWeek:nil];
    [self setBackgroundFill:nil];
    [self setAngleCut:nil];

    [self setCourseUniversityLb:nil];
    [self setNoSavedLecturesTxt:nil];
    [super viewDidUnload];
}


#pragma mark - View Configuration

- (void) configureResourcePopover {
    resourceDownloadViewController = [[ResourceDownloadViewController alloc] initWithNibName:@"ResourceDownloadViewController" bundle:nil];
    resourcePopover = [[UIPopoverController alloc] initWithContentViewController:resourceDownloadViewController];
    resourcePopover.popoverContentSize = CGSizeMake(300, 266);
    resourceDownloadViewController.popover = resourcePopover;
    
    [MBPopoverBackgroundView initialize];
    [PopoverCommonBackground setArrowImageName:@"arrow2.png"];
    [PopoverCommonBackground setBackgroundImageName:@"popover-border3.png"];
    [PopoverCommonBackground setBackgroundImageCapInsets:UIEdgeInsetsMake(3, 3, 3, 3)];
    [PopoverCommonBackground setContentViewInsets:UIEdgeInsetsMake(3, 3, 3, 3)];
    resourcePopover.popoverBackgroundViewClass = [PopoverCommonBackground class];
}

- (void) initDownloadControlContainers {
    if(downloadButtons == nil) {
        downloadButtons = [[NSMutableDictionary alloc] init];
    }

    if(resourceButtons == nil) {
        resourceButtons = [[NSMutableDictionary alloc] init];
    }

    if(accessoryViews == nil) {
        accessoryViews = [[NSMutableDictionary alloc] init];
    }
}

- (void) configureGlobalDownloadView {
    //// Download Control
    [[CSTDownloadControlButton sharedCSTDownloadControlButton] downloadControlViewController].pauseBlock = ^(NSString *key) {
        
        DownloadProgressView *dpv = [downloadButtons valueForKey:key];
        if(dpv != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                dpv.downloadButton.selected = NO;
            });
        }
    };
    [[CSTDownloadControlButton sharedCSTDownloadControlButton] downloadControlViewController].resumeBlock = ^(NSString *key) {
        
        DownloadProgressView *dpv = [downloadButtons valueForKey:key];
        if(dpv != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                dpv.downloadButton.selected = YES;
            });
        }
    };
    [[CSTDownloadControlButton sharedCSTDownloadControlButton] downloadControlViewController].resumeFirstTimeBlock = ^(void) {
        [self resumeSavedItems];
    };
}

- (void) updateCourseInfo {
    
    NSString *imageToLoad = [selectedCourse valueForKey:@"image_link"];
    NSString *courseTitleText = [selectedCourse valueForKey:@"title"];
    
    NSDate *startDate = [CollectionUtils extractDate:[selectedCourse objectForKey:@"start_date"]];
    NSDate *endDate = [CollectionUtils extractDate:[selectedCourse objectForKey:@"end_date"]];

    BOOL archived = self.switchArchivedRound.on;
    
    NSString *state = [CollectionUtils courseState:startDate endDate:endDate actual:[selectedCourse objectForKey:@"actual"] archived:archived];
    
    NSString *startDateDisplayStr = (startDate != nil) ? [NSDateFormatter localizedStringFromDate:startDate dateStyle:NSDateFormatterShortStyle timeStyle: NSDateFormatterNoStyle] : @"Regular";
    
    NSString *courseDescText = [[NSString alloc] initWithFormat:@"Provider: %@\nCategory: %@", [selectedCourse valueForKey:@"provider"], self.courseBranchName];
    
    
    [self.courseUniverLb setText:[courseDescText uppercaseString]  afterInheritingLabelAttributesAndConfiguringWithBlock:^ NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        NSRange providerRange = [[mutableAttributedString string] rangeOfString:@"Provider:"];
        NSRange categoryRange = [[mutableAttributedString string] rangeOfString:@"Category:"];
               
        
        // Core Text APIs use C functions without a direct bridge to UIFont. See Apple's "Core Text Programming Guide" to learn how to configure string attributes.
        UIFont *boldSystemFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16];
        CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)boldSystemFont.fontName, boldSystemFont.pointSize, NULL);
        if (font) {
            [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:providerRange];
            [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:categoryRange];
            CFRelease(font);
        }
        
        return mutableAttributedString;
    }];
    
    
    
    
    courseDescText = [[NSString alloc] initWithFormat:@"State: %@\nStart Date: %@", state, startDateDisplayStr];
    
    [self.courseDescLb setText:[courseDescText uppercaseString]  afterInheritingLabelAttributesAndConfiguringWithBlock:^ NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        NSRange stateRange = [[mutableAttributedString string] rangeOfString:@"State:"];
        NSRange startDateRange = [[mutableAttributedString string] rangeOfString:@"Start Date:"];

        
        // Core Text APIs use C functions without a direct bridge to UIFont. See Apple's "Core Text Programming Guide" to learn how to configure string attributes.
       
        UIFont *boldSystemFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16];
        CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)boldSystemFont.fontName, boldSystemFont.pointSize, NULL);
        if (font) {
            [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:stateRange];
            [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:startDateRange];
            CFRelease(font);
        }
        
        return mutableAttributedString;
    }];
    
    courseDescText = [[NSString alloc] initWithFormat:@"Sections: %d\nLectures: %d", weeks.count, expandedWeeks.count-weeks.count];

    
    [self.courseDescLb2 setText:[courseDescText uppercaseString] afterInheritingLabelAttributesAndConfiguringWithBlock:^ NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        NSRange sectionsRange = [[mutableAttributedString string] rangeOfString:@"Sections:"];
        NSRange lecturesRange = [[mutableAttributedString string] rangeOfString:@"Lectures:"];
        
        
        // Core Text APIs use C functions without a direct bridge to UIFont. See Apple's "Core Text Programming Guide" to learn how to configure string attributes.
        //UIFont *boldSystemFont = [UIFont boldSystemFontOfSize:14];
        UIFont *boldSystemFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16];
        CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)boldSystemFont.fontName, boldSystemFont.pointSize, NULL);
        if (font) {
            [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:sectionsRange];
            [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:lecturesRange];
            CFRelease(font);
        }
        
        return mutableAttributedString;
    }];
    
    
   
    //self.courseTitleLb.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:17];
    [self.courseTitleLb setText: [courseTitleText uppercaseString]];
    
    [self.courseUniversityLb setText: [[selectedCourse valueForKey:@"university"] uppercaseString]];
    
    [self.courseProviderLb setText: [providerName uppercaseString]];
    //self.courseProviderLb.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:14];
    
    if ([providerName isEqualToString:@"Coursera"]) {
        [self.courseProviderBG setImage:[UIImage imageNamed:@"week-Cour.png"]];
    } else {
        [self.courseProviderBG setImage:[UIImage imageNamed:@"week-Uda.png"]];
    }

    [self.courseImage sd_setImageWithURL:[NSURL URLWithString:imageToLoad]
                        placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    
    [self updateNumberOfCompletedLabel];
    
}

#pragma mark - Keys

- (NSString * ) baseKey {
    return self.navigationItem.title;
}

- (NSString * ) buttonKey:(NSInteger)i {
    //NSMutableString *key = [NSMutableString string];
    //[key appendString:[self baseKey]];
    
    NSString *key = [self baseKey];
    if(i >= 0) {
        key = [key stringByAppendingPathExtension:[@(i) description]];
        //[key appendString:[NSString stringWithFormat:@".%d", i]];
    }
    return key;
}

#pragma mark - Table Cell View Elements

- (UIView *) lectureAccessoryView:(NSString *)key {
    UIView *view = [accessoryViews valueForKey:key];
    if(view == nil) {
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 150, 50)];
        DownloadProgressView *dpv = [self lectureDownloadButton:key];
        if([providerName isEqualToString:@"Coursera"]) {
            UIButton *lrb = [self lectureResourceButton:key];
            lrb.frame = CGRectMake(100, 0, 50, 50);
            [view addSubview:lrb];
            dpv.frame = CGRectMake(50, 0, 50, 50);
        } else {
            dpv.frame = CGRectMake(100, 0, 50, 50);
        }
        [view addSubview:dpv];
        
        [accessoryViews setValue:view forKey:key];
    }
    return view;
}

- (void) updateLectureState:(NSInteger)i {
    DownloadItem *di = [self createDownloadItem:i url:nil];
    [self updateItemState:di];
}

- (void) updateItemState:(DownloadItem *)di {
        DownloadProgressView *dpv = [self lectureDownloadButton:di.key];

        //    dpv.downloadButton.selected = NO;
        BOOL downloadedState = [[DownloadManager sharedDownloadManager] isItemDownloaded:di];
        
        [dpv setDownloadedState:downloadedState];
        
        UIView *accessoryView = [self lectureAccessoryView:di.key];
    

        int imageTag = 0;
        for (UIView *view in [accessoryView subviews]) {
            if([view isKindOfClass:[UIImageView class]]) {
                //[view removeFromSuperview];
                imageTag = view.tag;
            }
        }
    
        if(downloadedState && imageTag !=10000 ) {
            [[accessoryView viewWithTag:20000] removeFromSuperview];
            UIImageView *downloadedImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hdd.png"]];
            if ([providerName isEqualToString:@"Coursera"]) {
                downloadedImage.frame = CGRectMake(17, 17, 16, 16);
            } else {
                downloadedImage.frame = CGRectMake(67, 17, 16, 16);
            }
            downloadedImage.tag = 10000;
            [accessoryView addSubview:downloadedImage];
        }
        else if ([[DownloadManager sharedDownloadManager] isItemEnqueued:di] && imageTag !=20000){
            
            UIImageView *enqueuedImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"inorder.png"]];
            if ([providerName isEqualToString:@"Coursera"]) {
                enqueuedImage.frame = CGRectMake(17, 17, 16, 16);
            } else {
                enqueuedImage.frame = CGRectMake(67, 17, 16, 16);
            }
            enqueuedImage.tag = 20000;
            [accessoryView addSubview:enqueuedImage];
            }
        else if (!downloadedState && ![[DownloadManager sharedDownloadManager] isItemEnqueued:di]){
            [[accessoryView viewWithTag:10000] removeFromSuperview];
            [[accessoryView viewWithTag:20000] removeFromSuperview];
            
            [[ProgressDataManager sharedProgressDataManager] updateProgress:di.key updateBlock:^(float progress) {
                dpv.progressView.progress = progress;
            }];
            
        }
    
    [accessoryViews setValue:accessoryView forKey:di.key];

//    }
}

- (DownloadProgressView *) lectureDownloadButton:(NSString *)key {
    DownloadProgressView *dpv = [downloadButtons valueForKey:key];
    if(dpv == nil) {
        NSArray *theView =  [[NSBundle mainBundle] loadNibNamed:@"DownloadProgressView" owner:self options:nil];
        dpv = [theView objectAtIndex:0];
        [dpv.downloadButton addTarget:self action:@selector(downloadButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [downloadButtons setValue:dpv forKey:key];

        dpv.downloadButton.tag = [[key pathExtension] intValue];
    }
    return dpv;
}

- (JSFlatButton *) categoryDownloadButton:(NSInteger)i  {
    NSString *key = [self buttonKey:i];
    JSFlatButton *button = [downloadButtons valueForKey:key];
    if(button == nil) {
        button = [[JSFlatButton alloc] initWithFrame: CGRectMake(0, 0, 250, 45) backgroundColor:[UIColor colorWithRed:152.0f/255.0f green:182.0f/255.0f blue:62.0f/255.0f alpha:1.0f] foregroundColor:[UIColor whiteColor]];
        
        [button setFlatImage:[UIImage imageNamed:@"downloadgr.png"]];
        
        [downloadButtons setValue:button forKey:key];
        
        button.tag = i;
    }
    
    return button;
}

- (JSQFlatButton *) categoryDownloadButtonAbove6_1:(NSInteger)i  {
    NSString *key = [self buttonKey:i];
    JSQFlatButton *button = [downloadButtons valueForKey:key];
    if(button == nil) {
        button = [[JSQFlatButton alloc] initWithFrame:CGRectMake(0, 0, 250, 45) backgroundColor:[UIColor colorWithRed:152.0f/255.0f green:182.0f/255.0f blue:62.0f/255.0f alpha:1.0f] foregroundColor:[UIColor whiteColor] title:@"" image:[UIImage imageNamed:@"downloadgr.png"]];
      
        [downloadButtons setValue:button forKey:key];

        button.tag = i;
    }

    return button;
}

- (void) updateCategoryButton:(NSInteger)categoryIndex {
    BOOL aboveIOS61 = kCFCoreFoundationVersionNumber > kCFCoreFoundationVersionNumber_iOS_6_1;
    if (aboveIOS61) {
        //    JSFlatButton *button = [self categoryDownloadButton:categoryIndex];
        JSQFlatButton *button = [self categoryDownloadButtonAbove6_1:categoryIndex];
        NSString *caption = [[expandedWeeks objectAtIndex:categoryIndex] valueForKey:@"title"];
        BOOL isInProgress = [[DownloadManager sharedDownloadManager] isQueueActive:[self buttonKey:categoryIndex]];
        if(isInProgress) {
            [button setFlatTitle:[@" Cancel " stringByAppendingString:caption]];
            [button removeTarget:self action:@selector(downloadCategoryButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            [button addTarget:self action:@selector(cancelDownloadCategoryButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        } else {
            [button setFlatTitle:[@" Download " stringByAppendingString:caption]];
            [button removeTarget:self action:@selector(cancelDownloadCategoryButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            [button addTarget:self action:@selector(downloadCategoryButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        }
    } else {
        JSFlatButton *button = [self categoryDownloadButton:categoryIndex];
        NSString *caption = [[expandedWeeks objectAtIndex:categoryIndex] valueForKey:@"title"];
        BOOL isInProgress = [[DownloadManager sharedDownloadManager] isQueueActive:[self buttonKey:categoryIndex]];
        if(isInProgress) {
            [button setFlatTitle:[@" Cancel " stringByAppendingString:caption]];
            [button removeTarget:self action:@selector(downloadCategoryButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            [button addTarget:self action:@selector(cancelDownloadCategoryButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        } else {
            [button setFlatTitle:[@" Download " stringByAppendingString:caption]];
            [button removeTarget:self action:@selector(cancelDownloadCategoryButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            [button addTarget:self action:@selector(downloadCategoryButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        }
        
    }
}

- (UIButton*) lectureResourceButton:(NSString*)key {
    UIButton *lrb = [resourceButtons objectForKey:key];
    if(lrb == nil) {
        lrb = [UIButton buttonWithType:UIButtonTypeCustom];
        lrb.tag = [[key pathExtension] intValue];
        int numberOfResourses =[[[expandedWeeks objectAtIndex:lrb.tag] objectForKey:@"resources"] count];
        if ( numberOfResourses == 1) {
            [lrb setImage:[UIImage imageNamed:@"lecture-resourses-1-num.png"] forState:UIControlStateNormal];
            [lrb setImage:[UIImage imageNamed:@"lecture-resourses-1-num.png"] forState:UIControlStateSelected];
            lrb.enabled = YES;
        } else if (numberOfResourses == 0) {
            [lrb setImage:[UIImage imageNamed:@"lecture-resourses-0.png"] forState:UIControlStateNormal];
            [lrb setImage:[UIImage imageNamed:@"lecture-resourses-0.png"] forState:UIControlStateSelected];
            lrb.enabled = NO;
        } else {
            [lrb setImage:[UIImage imageNamed:@"lecture-resourses.png"] forState:UIControlStateNormal];
            [lrb setImage:[UIImage imageNamed:@"lecture-resourses.png"] forState:UIControlStateSelected];
            lrb.enabled = YES;
        }

        [lrb addTarget:self action:@selector(showResourcesAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [resourceButtons setObject:lrb forKey:key];
    }
    return lrb;
}

#pragma mark - Table View Control

- (BOOL) isCellSelectable:(NSInteger)row {

    if([self isVideoCell:row]) {
        DownloadItem *di = [self createDownloadItem:row url:nil];
        return ([OfflineDataManager sharedOfflineDataManager].online || [[DownloadManager sharedDownloadManager] isItemDownloaded:di]);
    } else if([self isReferenceCell:row]) {
        return [OfflineDataManager sharedOfflineDataManager].online;
    } else {
        return false;
    }
}

- (BOOL) isCategoryCell:(NSInteger)row {
    
    NSDictionary *currentItem = [expandedWeeks objectAtIndex:row];
    return [currentItem valueForKey:@"courseware"] != nil;
}

- (BOOL) isVideoCell:(NSInteger)row {
    
    NSDictionary *lecture = [expandedWeeks objectAtIndex:row];
    return ([lecture valueForKey:@"video_link"] != nil) || ([lecture valueForKey:@"youtube_link"] != nil);
}

- (BOOL) isReferenceCell:(NSInteger)row {
    
    NSDictionary *lecture = [expandedWeeks objectAtIndex:row];
    return [lecture objectForKey:@"web_link"] != nil;
}


#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [expandedWeeks count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *currentItem = [expandedWeeks objectAtIndex:indexPath.row];
    BOOL isCategoryCell = [self isCategoryCell:indexPath.row];
   
    if(isCategoryCell) {
        static NSString *CellIdentifierCategory = @"CellCategory";
        //UITableViewCell *cellCategory = [tableView dequeueReusableCellWithIdentifier:CellIdentifierCategory];
        CSTWeekTableViewCellCategory *cellCategory = [tableView dequeueReusableCellWithIdentifier:CellIdentifierCategory];
        if (nil == cellCategory) {
            cellCategory = [[CSTWeekTableViewCellCategory alloc]
                    initWithStyle: UITableViewCellStyleDefault
                    reuseIdentifier:CellIdentifierCategory];
            cellCategory.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
            cellCategory.selectionStyle = UITableViewCellSelectionStyleNone;

        }

        
        cellCategory.textLabel.text = [self htmlEntityDecode:[currentItem valueForKey:@"title"]];
        [self updateCategoryButton:indexPath.row];
        
        UIButton *categoryDownloadButton = [self categoryDownloadButton:indexPath.row];
        if([OfflineDataManager sharedOfflineDataManager].online) {
            categoryDownloadButton.backgroundColor = [UIColor colorWithRed:152.0f/255.0f green:182.0f/255.0f blue:62.0f/255.0f alpha:1.0f];
            categoryDownloadButton.userInteractionEnabled = YES;
        } else {
            categoryDownloadButton.backgroundColor = [UIColor grayColor];
            categoryDownloadButton.userInteractionEnabled = NO;
        }
        
        cellCategory.accessoryView = categoryDownloadButton;
        
        return cellCategory;
        
    } else {
        static NSString *CellIdentifier = @"Cell";
        CSTWeekTableViewCellVideo *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (nil == cell) {
            cell = [[CSTWeekTableViewCellVideo alloc]
                    initWithStyle: UITableViewCellStyleSubtitle
                    reuseIdentifier:CellIdentifier];
            
            int completeButtonInset = 20;
            BOOL belowIOS7 = kCFCoreFoundationVersionNumber <= kCFCoreFoundationVersionNumber_iOS_6_1;
            if (belowIOS7) {
                completeButtonInset = 40;
            }
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(completeButtonInset, 50), NO, 0.0);
            UIImage *blank = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            cell.imageView.image = blank;
            
            
            
            cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
            cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Regular" size:10];
            
        } else {
           
            for (UIView *subview in [cell.contentView subviews]) {
                if (subview.tag > 0) {
                    [subview removeFromSuperview];
                 }
            }
        }
        
        if([self isVideoCell:indexPath.row]) {
            
            
            cell.accessoryView = [self lectureAccessoryView:[self buttonKey:indexPath.row]];
            [self updateLectureState:indexPath.row];
            /////completed button
            UIButton *completedButton = [self completedButton:indexPath.row];

            [cell.contentView addSubview:completedButton];
            
            

            DownloadProgressView *dpv = [self lectureDownloadButton:[self buttonKey:indexPath.row]];


            if([self isCellSelectable:indexPath.row]) {
                cell.selectionStyle = UITableViewCellSelectionStyleBlue;
                [dpv setEnabled:YES];
            } else {
                cell.selectionStyle = UITableViewCellSelectionStyleNone;

                [dpv setEnabled:NO];
            }

            
            
            /////
        } else if([self isReferenceCell:indexPath.row]) {
            cell.accessoryView = nil;
            
            /////completed button
            UIButton *completedButton = [self completedButton:indexPath.row];
            
            [cell.contentView addSubview:completedButton];
            if([self isCellSelectable:indexPath.row]) {
                cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            } else {
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
        } else {
            cell.accessoryView = nil;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        if([currentItem valueForKey:@"subtitle"] != nil) {
            [cell.detailTextLabel setText:[currentItem valueForKey:@"subtitle"]];
        } else {
            [cell.detailTextLabel setText:@""];
        }
        
        cell.textLabel.text = [self htmlEntityDecode:[currentItem valueForKey:@"title"]] ;
        
        return cell;
    }

    return nil;
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {

    if([self isCategoryCell:indexPath.row]) {       
        cell.backgroundColor = [UIColor colorWithRed:214.0f/255.0f green:214.0f/255.0f blue:214.0f/255.0f alpha:1.0f];
        cell.textLabel.textColor = [UIColor whiteColor];
    } else {
        cell.textLabel.textColor = [UIColor blackColor];
        if(cell.selectionStyle == UITableViewCellSelectionStyleNone) {
            cell.backgroundColor = [UIColor lightGrayColor];
        } else {
            cell.backgroundColor = [UIColor whiteColor];
        }
    }
    
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self isCellSelectable:indexPath.row])
    {
        return indexPath;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self isVideoCell:indexPath.row]) {
        videoIdSelectedForPlay = indexPath.row;
        DownloadItem *di = [self createDownloadItem:indexPath.row url:nil];
        if(![[DownloadManager sharedDownloadManager] isItemDownloaded:di]) {

            [self requestSingleVideoLink:indexPath.row processingBlock:^(NSArray *items) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    DownloadProgressView *dpv = [self lectureDownloadButton:[self buttonKey:indexPath.row]];
                    [dpv stopPreparation];
                    
                    
                    if(items.count < 2) {
                        [ToastView showToastInParentView:self.view withText:@"Impossible to play video. Write to message to support team in order to solve this." withDuaration:5.0];
                    }
                    NSString *videoLink = [[items objectAtIndex:1] objectForKey:@"video_link"];
                    NSURL *videoURL = [NSURL URLWithString:videoLink];
                    NSString *quizLink = [[items objectAtIndex:1] objectForKey:@"quiz_link"];
                    NSURL *quizURL = quizLink != nil ? [NSURL URLWithString:quizLink] : nil;
                    NSArray *subtitles = [[items objectAtIndex:1] objectForKey:@"subtitles"];

                    NSArray *reversedSubtitles = [[subtitles reverseObjectEnumerator] allObjects];
#ifndef LITE_VERSION
                    DownloadItem *di = [self createDownloadItem:videoIdSelectedForPlay url:nil];
                    
                    [self subtitlesDownload:reversedSubtitles lectureDownloadItem:di];
#endif

                    [self playVideo:indexPath.row videoURL:videoURL quizURL:quizURL subtitles:reversedSubtitles title:di.lectureTitle];
                });
                
            }];
        } else {
            
            NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:[DownloadManager filePath:di]];

            // the empty array of subtitles is created to notify player, that subtitles should be taken from file system
            [self playVideo:indexPath.row videoURL:fileURL quizURL:nil subtitles:[[NSArray alloc] init] title:di.lectureTitle];
        }
        ///// set last opened video index
        lastSelectedVideoIndex = indexPath.row;
        
        NSDictionary *videoParams = [NSDictionary dictionaryWithObjectsAndKeys: providerName, @"Provider",
                                                                                [selectedCourse valueForKey:@"title"], @"Course",
                                                                                [[expandedWeeks objectAtIndex:indexPath.row] valueForKey:@"title"], @"VideoTitle",
                                                                                nil];
        
        [Flurry logEvent:@"Video_Playback" withParameters:videoParams];
        
        
        
    } else if([self isReferenceCell:indexPath.row]) {
        if (webViewController == nil){
            webViewController = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil];
        }
        NSDictionary *quiz = [expandedWeeks objectAtIndex:indexPath.row];
        NSString *quizLink = [[selectedCourse valueForKey:@"web_link"] stringByAppendingString:[quiz valueForKey:@"web_link"]];
        [webViewController navigationItem].title = quizLink;
        
        //NSString *encodedString=[quizLink stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        webViewController.resourceURL = [NSURL URLWithString:quizLink];

        [self.navigationController pushViewController:webViewController animated:YES];
    }
    

    
}

#pragma mark - Utility section

- (void)setWeeks:(NSArray *)newWeeks {
    if(newWeeks != weeks) {
        weeks = newWeeks;
        expandedWeeks = [CollectionUtils expandArray:newWeeks nodeKey:@"courseware"];
        
        [self.tableWeek reloadData];
    }
}

#pragma mark - Play video

- (void) playVideo:(NSInteger)index videoURL:(NSURL *)videoURL quizURL:(NSURL *)quizURL subtitles:(NSArray*)subtitles title:(NSString *)title
{
    
    self.lectureViewController.lectureDownloadItem = [self createDownloadItem:index url:nil];
    self.lectureViewController.url = videoURL;
    self.lectureViewController.subtitles = subtitles;
    NSError *error;
    if ([OfflineDataManager sharedOfflineDataManager].online && quizURL != nil) {
        
        self.lectureViewController.quizCode = [NSString stringWithContentsOfURL:quizURL encoding:NSUTF8StringEncoding error:&error];
        if(error) {
            self.lectureViewController.quizCode = nil;
        }
    }
    self.lectureViewController.title = title;
    [self.navigationController pushViewController:self.lectureViewController animated:YES];
}


#pragma mark - Extract video links

-(void) requestSingleVideoLink:(int)currentItemIndex processingBlock:(void (^)(NSArray*))processingBlock {
    
    NSDictionary *lecture = [expandedWeeks objectAtIndex:currentItemIndex];
    
    DownloadProgressView *dpv = [self lectureDownloadButton:[self buttonKey:currentItemIndex]];
    [dpv startPreparation];
    if([providerName isEqualToString:@"Coursera"]) {
        NSString *lectureViewLink = [[lecture objectForKey:@"video_link"] stringByReplacingOccurrencesOfString:@"download.mp4" withString:@"view"];

        [(LinkProcessingDelegate *)[videoProcessingManager delegate ]registerBlock:processingBlock forLink:lectureViewLink];
        [videoProcessingManager readContent:[NSURL URLWithString:lectureViewLink] title:@""];
    }
    else if([providerName isEqualToString:@"Udacity"]){
        NSString *videoLink = [lecture valueForKey:@"youtube_link"];
        [self extractYoutubeLink:videoLink processingBlock:processingBlock];
    }
}

- (void) extractYoutubeLink:(NSString *)videoLink processingBlock:(void (^)(NSArray*))processingBlock {

    LBYouTubeExtractor *youtubeExtractor = [[LBYouTubeExtractor alloc] initWithURL:[NSURL URLWithString:videoLink] quality:LBYouTubeVideoQualityLarge];

    [youtubeExtractor extractVideoURLWithCompletionBlock:^(NSURL *videoURL, NSError *error) {
        if(error == nil) {
            NSArray *items = [[NSArray alloc] initWithObjects:videoURL, nil];
            processingBlock(items);
        }
    }];     
}

#pragma mark - Download

- (BOOL) isItemReadyForSingleDownload:(DownloadItem *)di {
    BOOL notSingle = ![[DownloadManager sharedDownloadManager] isItemSingle:di];
    BOOL notDownloaded = ![[DownloadManager sharedDownloadManager] isItemDownloaded:di];
    return notSingle && notDownloaded;
}

- (BOOL) isItemReadyForAutoDownload:(DownloadItem *)di {
    return ![[DownloadManager sharedDownloadManager] isItemEnqueued:di] && ![[DownloadManager sharedDownloadManager] isItemSingle:di] && ![[DownloadManager sharedDownloadManager] isItemDownloaded:di];
}

- (void) downloadButtonAction:(id)sender {
    UIButton *button = (UIButton *)sender;
    int lectureIndex = button.tag;
    
    NSDictionary *eventParam = [NSDictionary dictionaryWithObjectsAndKeys: @"pause", @"actionType", nil];
    
    DownloadProgressView* dpv = [self lectureDownloadButton:[self buttonKey:lectureIndex]];
    // DownloadItem without valid url for downloaded state verification
    DownloadItem *diStub = [self createDownloadItem:lectureIndex url:nil];
    
    AFDownloadRequestOperation *operation = [[DownloadManager sharedDownloadManager] operationForItem:diStub];
    if(operation != nil && ![self isItemReadyForSingleDownload:diStub]) {
        if([operation isExecuting]) {
            [operation pause];
            dpv.downloadButton.selected = NO;

        } else {
            [operation resume];
            dpv.downloadButton.selected = YES;
            eventParam = [NSDictionary dictionaryWithObjectsAndKeys: @"resume", @"actionType", nil];
            [Flurry logEvent:@"SingleDownload_pressed" withParameters:eventParam];
        }
    } else if([[DownloadManager sharedDownloadManager] isItemDownloaded:diStub]) {
//        BOOL test = [[NSUserDefaults standardUserDefaults] boolForKey:@"delete_confirmation_full"];
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"delete_confirmation_full"]) {
            eventParam = [NSDictionary dictionaryWithObjectsAndKeys: @"delete", @"actionType", nil];

            UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"Delete lecture" message:@"Are you sure?" delegate:nil cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
            [alert showAlerViewFromButtonAction:nil animated:YES handler:^(UIAlertView *alertView, NSInteger buttonIndex){
                if(buttonIndex == 1) {
                    [[DownloadManager sharedDownloadManager] deleteItem:diStub];
                    diStub.extension = @"srt";
                    [[DownloadManager sharedDownloadManager] deleteItem:diStub];
                    [self updateLectureState:lectureIndex];
                }
            }];
        } else {
            [[DownloadManager sharedDownloadManager] deleteItem:diStub];
            diStub.extension = @"srt";
            [[DownloadManager sharedDownloadManager] deleteItem:diStub];
            [self updateLectureState:lectureIndex];
        }
        

    } else {
        if([providerName isEqualToString:@"Coursera"]) {
            [self lectureDownload:lectureIndex queueKey:nil];
            eventParam = [NSDictionary dictionaryWithObjectsAndKeys: @"SingleDownload", @"actionType", providerName,@"provider", nil];
        } else {
            NSURL *youtubeURL = [NSURL URLWithString:[[expandedWeeks objectAtIndex:lectureIndex] objectForKey:@"youtube_link"]];
            
            eventParam = [NSDictionary dictionaryWithObjectsAndKeys: @"SingleDownload", @"actionType", providerName,@"provider", nil];
            
            [youtubeURLManager loadURLS:@[youtubeURL] completionBlock:^{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self lectureDownload:lectureIndex queueKey:nil];
                });
            }];
        }
    }
    [Flurry logEvent:@"SingleDownload_pressed" withParameters:eventParam];
}

- (void) lectureDownload:(NSInteger)lectureIndex queueKey:(NSString *)queueKey {

    NSDictionary *lecture = [expandedWeeks objectAtIndex:lectureIndex];
    DownloadProgressView* dpv = [self lectureDownloadButton:[self buttonKey:lectureIndex]];
    
    NSURL *videoURL;
    NSURL *subtitleURL;
    if([providerName isEqualToString:@"Coursera"]) {
        videoURL = [NSURL URLWithString:[lecture valueForKey:@"video_link"]];
        subtitleURL = [NSURL URLWithString:[lecture valueForKey:@"subtitles_link"]];
        
    } else {
        NSURL *originalURL = [NSURL URLWithString:[lecture valueForKey:@"youtube_link"]];
        videoURL = [youtubeURLManager videoURL:originalURL];
        subtitleURL = nil;
    }
    
    if(videoURL == (id)[NSNull null]) {
        [CSTUIHelper showInstantMessage:@"Video URL is unavailable" targetView:dpv];
    } else {
        DownloadItem *di = [self createDownloadItem:lectureIndex url:videoURL];
        
        [self itemDownload:di queueKey:queueKey];
#ifndef LITE_VERSION
        [self prepareSubtitlesForLecture:lectureIndex];
#endif
    }
}

- (void) itemDownload:(DownloadItem *)di queueKey:(NSString *)queueKey {
    DownloadProgressView* dpv = [self lectureDownloadButton:di.key];
    [dpv stopPreparation];
    
    if([self isItemReadyForSingleDownload:di] || [self isItemReadyForAutoDownload:di]) {
        /////

        [[ProgressDataManager sharedProgressDataManager] initProgressForDownloadItem:di];
        DownloadProgressBlock downloadProgressBlock = ^(AFDownloadRequestOperation *operation, NSInteger bytesRead, long long totalBytesRead, long long totalBytesExpected, long long totalBytesReadForFile, long long totalBytesExpectedToReadForFile) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                float progress = totalBytesReadForFile/(float)totalBytesExpectedToReadForFile;
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(!dpv.downloadButton.selected) {
                        dpv.downloadButton.selected = YES;
                    }
                    dpv.progressView.progress = progress;
                });

                [[ProgressDataManager sharedProgressDataManager] storeProgress:progress key:di.key];
            });
        };
        

        
        SuccessCompletionBlock successCompletionBlock = ^(AFHTTPRequestOperation *operation, id responseObject) {
            
            [[ProgressDataManager sharedProgressDataManager] resetProgress:di.key];
            [[DownloadManager sharedDownloadManager] removeOperationByKey:di.key];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self updateItemState:di];
                [[CSTDownloadControlButton sharedCSTDownloadControlButton] update];
                
            });
        };
        
        FailureCompletionBlock failureCompletionBlock = ^(AFHTTPRequestOperation *operation, NSError *error) {
            [[DownloadManager sharedDownloadManager] removeOperationByKey:di.key];
            if(error.code == -1011) {
                // video is not available
                [[ProgressDataManager sharedProgressDataManager] resetProgress:di.key];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if(![operation isCancelled]) {                    
                    [CSTUIHelper showInstantError:error targetView:dpv];
                }
                [[CSTDownloadControlButton sharedCSTDownloadControlButton] update];
                [self updateItemState:di];
            });
        };
        
        if(queueKey != nil) {
            [[DownloadManager sharedDownloadManager] autoDownload:queueKey downloadItem:di downloadProgressBlock:downloadProgressBlock successCompletionBlock:successCompletionBlock failureCompletionBlock:failureCompletionBlock];

            
        } else {
            [[DownloadManager sharedDownloadManager] manualDownload:di downloadProgressBlock:downloadProgressBlock successCompletionBlock:successCompletionBlock failureCompletionBlock:failureCompletionBlock];
        }
        [self updateItemState:di];
        [[CSTDownloadControlButton sharedCSTDownloadControlButton] update];
    } else {
        // remove stale download
        [[ProgressDataManager sharedProgressDataManager] resetProgress:di.key];        
    }
    
}

- (IBAction)downloadCategoryButtonAction:(id)sender {
    UIButton *button = (UIButton *)sender;
    int categoryIndex = button.tag;

    NSDictionary *eventParam = [NSDictionary dictionaryWithObjectsAndKeys: providerName, @"provider", nil];
    [Flurry logEvent:@"CategoryDownload" withParameters:eventParam];
    
    if([providerName isEqualToString:@"Coursera"]) {
        [self categoryDownload:categoryIndex];

    } else {
        [CSTUIHelper addActivityView:button];
        int lectureIndex = categoryIndex+1;
        NSMutableArray* youtubeURLS = [[NSMutableArray alloc] init];
        while (![self isCategoryCell:lectureIndex] && (lectureIndex < [expandedWeeks count])) {
            if([self isVideoCell:lectureIndex]) {
                NSURL *youtubeURL = [NSURL URLWithString:[[expandedWeeks objectAtIndex:lectureIndex] objectForKey:@"youtube_link"]];
                
                [youtubeURLS addObject:youtubeURL];
            }
            lectureIndex++;
        }
        [youtubeURLManager loadURLS:youtubeURLS completionBlock:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [CSTUIHelper removeActivityView:button];

                [self categoryDownload:categoryIndex];
            });
        }];
    }
}

- (void) categoryDownload:(NSInteger)categoryIndex {
    NSString *key = [self buttonKey:categoryIndex];
    
    int lectureIndex = categoryIndex+1;
    int countOfExpandedWeeks = [expandedWeeks count];
    while ( (lectureIndex < countOfExpandedWeeks) && ![self isCategoryCell:lectureIndex]) {
        if([self isVideoCell:lectureIndex]) {
            DownloadItem *diStub = [self createDownloadItem:lectureIndex url:nil];
            if([self isItemReadyForAutoDownload:diStub]) {
                [self lectureDownload:lectureIndex queueKey:key];
            }
            if([providerName isEqualToString:@"Coursera"]) {
                [self resourcesDownload:lectureIndex lectureDownloadItem:diStub];
            }
        }
        
        lectureIndex++;
    }
    [[DownloadManager sharedDownloadManager] finishAutoDownloadWithBlock:key block:^{
        [[DownloadManager sharedDownloadManager] removeAutoDownloadQueue:key];
        [self updateCategoryButton:categoryIndex];
    }];
    [self updateCategoryButton:categoryIndex];
}

- (void) resourcesDownload:(NSInteger)lectureIndex lectureDownloadItem:(DownloadItem*)lectureDownloadItem{
    
    NSArray *resources = [[expandedWeeks objectAtIndex:lectureIndex] objectForKey:@"resources"];
    if([resources count] > 0) {
        for (int i = 0; i < resources.count; i++) {
            DownloadItem *di = [lectureDownloadItem mutableCopy];
            NSString *link = [[resources objectAtIndex:i] objectForKey:@"link"];
            di.key = link;
            di.url = [NSURL URLWithString:link];
            NSString *fullFileName = [[link  stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] lastPathComponent];
            NSString *fileExtension = [fullFileName pathExtension];
            NSString *fileName = [fullFileName stringByDeletingPathExtension];
            
            fullFileName = [fileName stringByAppendingPathExtension:fileExtension];
            if([fileName rangeOfString:@"subtitles"].location == NSNotFound) {
                fullFileName = [fullFileName stringByReplacingOccurrencesOfString:@"&" withString:@"_"];
                
                if(fileExtension == nil || [fileExtension isEqualToString:@""]) {
                    fileExtension = @".txt";
                }
                if([fullFileName rangeOfString:fileExtension].location == NSNotFound) {
                    fullFileName = [fileName stringByAppendingPathExtension:fileExtension];
                }
                
            } else {
                fullFileName = @"subtitles.txt";
            }
            di.extension = fullFileName;

            DownloadManager *manager = [DownloadManager sharedDownloadManager];
            if(![manager isItemDownloaded:di]) {
                [manager resourceDownload:di downloadProgressBlock:nil successCompletionBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
                } failureCompletionBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
                    
                }];
            }
        }
    }
}

- (void) prepareSubtitlesForLecture:(int)itemIndex {
    if([providerName isEqualToString:@"Coursera"] && [OfflineDataManager sharedOfflineDataManager].online) {
        
        DownloadItem *di = [self createDownloadItem:itemIndex url:nil];
        NSDictionary *lecture = [expandedWeeks objectAtIndex:itemIndex];
        NSString *lectureViewLink = [[lecture objectForKey:@"video_link"] stringByReplacingOccurrencesOfString:@"download.mp4" withString:@"view"];
        
        
        [(LinkProcessingDelegate *)[subtitleProcessingManager delegate] registerBlock:^(NSArray *items) {
            if(items.count > 1) {
                NSArray *subtitles = [[items objectAtIndex:1] objectForKey:@"subtitles"];
//                NSArray* reversedSubtitles = [[subtitles reverseObjectEnumerator] allObjects];
                [self subtitlesDownload:subtitles lectureDownloadItem:di];
            }
        } forLink:lectureViewLink];
        [subtitleProcessingManager readContent:[NSURL URLWithString:lectureViewLink] title:@""];
    }
}

- (void) subtitlesDownload:(NSArray *)subtitles lectureDownloadItem:(DownloadItem*)lectureDownloadItem {
    if([subtitles count] > 0) {
        NSMutableArray *subtitlesListForDownload = [subtitles mutableCopy];
        // make default subtitle first
        
        if([SettingsHelper isDefaultLanguageDefined]) {
            for (int i = 0; i < subtitles.count; i++) {
                NSDictionary *item = [subtitles objectAtIndex:i];
                if([SettingsHelper isLanguageEqualToDefault:[item objectForKey:@"language"]]) {
                    [subtitlesListForDownload removeObjectAtIndex:i];
                    [subtitlesListForDownload insertObject:item atIndex:0];
                    break;
                }
            }
        }
  
        for (int i = 0; i < subtitlesListForDownload.count; i++) {
            DownloadItem *di = [lectureDownloadItem mutableCopy];
            NSString *link = [[subtitlesListForDownload objectAtIndex:i] objectForKey:@"link"];
            di.key = link;
            di.url = [NSURL URLWithString:link];
            NSString *subtitleName = [[link  stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] lastPathComponent];
            
            NSArray *items = [subtitleName componentsSeparatedByString:@"_"];
            
            if(items.count > 1) {
                di.extension = [[@"subtitles." stringByAppendingString:[items objectAtIndex:1]] stringByAppendingString:@".srt"];
            } else {
                di.extension = @"subtitles.???.srt";
            }
            
            DownloadManager *manager = [DownloadManager sharedDownloadManager];
            if(![manager isItemDownloaded:di]) {
                @weakify(self)
                [manager resourceDownload:di downloadProgressBlock:nil successCompletionBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
                    // nothing to do, actually
                } failureCompletionBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
                    @strongify(self)
                    [ToastView showToastInParentView:self.view withText:[[NSString alloc] initWithFormat:@"Unable to download subtitles: %@", [error localizedDescription] ] withDuaration:3.0f];
                }];
            }
        }
    }

}

- (IBAction)cancelDownloadCategoryButtonAction:(id)sender {
    UIButton *button = (UIButton *)sender;
    int categoryIndex = button.tag;
    NSString *key = [self buttonKey:categoryIndex];
    
    [[DownloadManager sharedDownloadManager] removeAutoDownloadQueue:key];
    int lectureIndex = categoryIndex+1;
    while ((lectureIndex < [expandedWeeks count]) && ![self isCategoryCell:lectureIndex]) {
        if([self isVideoCell:lectureIndex]) {
            [self updateLectureState:lectureIndex];
        }
        lectureIndex++;
    }
    [self updateCategoryButton:categoryIndex];
}

- (NSString *) providerCode {
    if([@"Coursera" isEqualToString:providerName]) {
        return @"CSR";
    } else if([@"Udacity" isEqualToString:providerName]) {
        return @"UDT";
    } else {
        return @"UKN";
    }
}

-(void) resumeSavedItems {
    for (NSString *itemKey in [[ProgressDataManager sharedProgressDataManager] storedKeys]) {
        DownloadItem *di = [[ProgressDataManager sharedProgressDataManager] downloadItem:itemKey];
        [self itemDownload:di queueKey:@"resumedDownloads"]; // add some queue key
    }
}

-(DownloadItem *) createDownloadItem:(NSInteger)itemIndex url:(NSURL *)url {
    NSDictionary *item = [expandedWeeks objectAtIndex:itemIndex];
    
    NSString *extension = @"mp4";
    if([url.absoluteString hasSuffix:@"srt"]) {
        extension = @"srt";
    }
    
    DownloadItem *di = [[DownloadItem alloc] init:[self buttonKey:itemIndex] provider:[self providerCode] lectureItem:item courseTitle:[selectedCourse valueForKey:@"title"] extension:extension];
    
    di.url = url;
    return di;
}

#pragma mark - Resources Section

- (void) showResourcesAction:(id)sender {
    UIButton *b = sender;
    resourceDownloadViewController.weekViewController = self;
    resourceDownloadViewController.resources = [[expandedWeeks objectAtIndex:b.tag] objectForKey:@"resources"];
    resourceDownloadViewController.lectureDownloadItem = [self createDownloadItem:b.tag url:nil];
    [resourcePopover presentPopoverFromRect:b.frame inView:b.superview permittedArrowDirections:UIPopoverArrowDirectionRight animated:NO];
}

#pragma mark - Utility Section


- (void)switchArchivedChanged:(id)sender {
    
    [[NSUserDefaults standardUserDefaults] setBool:self.switchArchivedRound.on forKey:[self getUserDefaultsLectureKey]];

}

- (void)saveLastViewedVideo:(NSInteger)index {
    
    NSString *lastVideoKey = [@"videoIndex-" stringByAppendingString:[self getUserDefaultsLectureKey]];
    [[NSUserDefaults standardUserDefaults] setInteger:index forKey:lastVideoKey];

}

- (NSString *)getUserDefaultsLectureKey {
    
    NSString *userDefaultsLectureKey;
    if ([[[selectedCourse valueForKey:@"provider"]description] isEqualToString:@"Coursera"]) {
        userDefaultsLectureKey = [[NSString alloc] initWithFormat:@"%@-%@-%@",[[selectedCourse valueForKey:@"provider"]description],[[selectedCourse valueForKey:@"title"]description],[[[selectedCourse valueForKey:@"start_date"]description]substringToIndex:10]];
    } else {
        userDefaultsLectureKey = [[NSString alloc] initWithFormat:@"%@-%@",[[selectedCourse valueForKey:@"provider"]description],[[selectedCourse valueForKey:@"title"]description]];
        
    }
    
    return userDefaultsLectureKey;
    
}


- (UIButton *) completedButton:(NSInteger)i {
    NSString *key = [self buttonKey:i];
    
    UIButton *completedButton = [completedButtons valueForKey:key];
    if(completedButton == nil) {
        completedButton = [UIButton buttonWithType:UIButtonTypeCustom];
        completedButton.selected = NO;
        completedButton.frame = CGRectMake(0, 0, 50, 50);
        
        completedButton.center = CGPointMake(20,self.tableWeek.rowHeight/2);
        [completedButton setImage:[UIImage imageNamed:@"Check-active.png"] forState:UIControlStateSelected];
        
        [completedButton setImage:[UIImage imageNamed:@"Check-passive.png"] forState:UIControlStateNormal];
        [completedButton addTarget:self action:@selector(setCompletedButton:)forControlEvents:UIControlEventTouchUpInside];
        [completedButtons setObject:completedButton forKey:key];
        completedButton.tag = i;
    }
    NSNumber *state = [completedButtonStates objectForKey:key];
    if(state != nil) {
        completedButton.selected = [state boolValue];
    } else {
        completedButton.selected = NO;
    }
    return completedButton;
}

-(void)setCompletedButton:(UIButton *) sender{
    int itemIndex = sender.tag;
    NSString *key = [self buttonKey:itemIndex];
    if (!sender.selected) {
        numberOfCompletedCourses++;
    } else {
        
        numberOfCompletedCourses--;
    }
    [self updateNumberOfCompletedLabel];
    
    
    sender.selected=!sender.selected;
    [completedButtonStates setValue:[[NSNumber alloc] initWithBool:sender.selected] forKey:key];

}
-(void)setCompletedButtonAfterVideoFinished{
    NSString *key = [self buttonKey:videoIdSelectedForPlay];
    UIButton *completedButton = [completedButtons valueForKey:key];
    if(completedButton != nil) {
        if (!completedButton.selected) {
            numberOfCompletedCourses++;
            [self updateNumberOfCompletedLabel];
            completedButton.selected = YES;
            [completedButtonStates setValue:[[NSNumber alloc] initWithBool:YES] forKey:key];
        }
    }
    
    
}

- (void) updateNumberOfCompletedLabel {
    
    NSString *completedStr = [[NSString alloc] initWithFormat:@"Completed: %i", numberOfCompletedCourses];
    if ((expandedWeeks.count-weeks.count) == 0 ) {
        progressBarWeek.progress = 0.0;
    } else {
        progressBarWeek.progress = (double)numberOfCompletedCourses/(expandedWeeks.count-weeks.count);
    }

    
    [self.courseDescNuberCoursesLbl setText:[completedStr uppercaseString]  afterInheritingLabelAttributesAndConfiguringWithBlock:^ NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {

        NSRange completedRange = [[mutableAttributedString string] rangeOfString:@"Completed:"];
        
        // Core Text APIs use C functions without a direct bridge to UIFont. See Apple's "Core Text Programming Guide" to learn how to configure string attributes.
        UIFont *boldSystemFont = [UIFont fontWithName:@"HelveticaNeue" size:16];
        CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)boldSystemFont.fontName, boldSystemFont.pointSize, NULL);
        if (font) {

            [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:completedRange];
            CFRelease(font);
        }
        
        return mutableAttributedString;
    }];
    
}

- (BOOL) isDownloadLinksAvailable {
    for(NSDictionary *lecture in expandedWeeks) {
        if(([lecture objectForKey:@"video_link"] != nil) || ([lecture objectForKey:@"youtube_link"] != nil)) {
            return YES;
        }
    }
    return NO;
}


- (IBAction)courseWebBtnPressed:(id)sender {
    
        if (webViewController == nil){
            webViewController = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil];
        }
        NSString *courseLink = [selectedCourse valueForKey:@"web_link"];
        [webViewController navigationItem].title = courseLink;
    
    
        //NSString *encodedString=[courseLink stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        webViewController.resourceURL = [NSURL URLWithString:courseLink];
    

        [self.navigationController pushViewController:webViewController animated:YES];

//    NSDictionary *eventParam = [NSDictionary dictionaryWithObjectsAndKeys: self.courseTitleLb.text, @"course", nil];
    [Flurry logEvent:@"courseWebBtnPressed"];
    
    
}

- (IBAction)deleteAll {
    UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"Delete all downloaded files" message:@"You've just requested deletion of all downloaded course related videos and resources. Are you sure?" delegate:nil cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [alert showAlerViewFromButtonAction:nil animated:YES handler:^(UIAlertView *alertView, NSInteger buttonIndex){
        if(buttonIndex == 1) {
            NSString *courseFolder = [DownloadManager folderPath:[self providerCode] courseTitle:[selectedCourse valueForKey:@"title"]];
            NSError *error;
            BOOL success = [[NSFileManager defaultManager] removeItemAtPath:courseFolder error:nil];
            if(!success) {
                [[[UIAlertView alloc] initWithTitle:@"Error occured" message:[[NSString alloc] initWithFormat:@"The following error occured while deleting all course related videos and resources: %@", [error localizedDescription]] delegate:nil cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil] show];
                
            } else {
                [self.tableWeek reloadData];
            }
        }
    }];
//    NSDictionary *eventParam = [NSDictionary dictionaryWithObjectsAndKeys: self.courseTitleLb.text, @"course", nil];
//    [Flurry logEvent:@"deleteAll" withParameters:eventParam];
}

-(NSString *)htmlEntityDecode:(NSString *)string
{
    string = [string stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
    string = [string stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
    string = [string stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    string = [string stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
    string = [string stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
    
    return string;
}

#pragma mark -
#pragma mark UIDocumentInteractionControllerDelegate

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)interactionController
{
    return self.navigationController;
}


@end
