//
//  CSTWeekViewController.h
//  Coursistant05
//
//  Created by Администратор on 7.3.13.
//  Copyright (c) 2013 Администратор. All rights reserved.


#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

#import "IContentDelegate.h"
#import "IProviderService.h"


#import "LBYouTubeExtractor.h"
#import "CourseraVideoLinkManager.h"
#import "CourseraVideoLinkDelegate.h"

#import "LectureViewController.h"
#import "TTTAttributedLabel.h"
#import "YouTubeURLManager.h"
#import "ProgressDataManager.h"

#import "DCRoundSwitch.h"
#import "MCProgressBarView.h"
#import "ResourceDownloadViewController.h"
#import "WebViewController.h"
#import "CourseraPlayerManager.h"
#import "LinkProcessingDelegate.h"

typedef enum {VideoTargetView1=0, VideoTargetDownload1} VideoTarget1;

//@class CSTCourse;


@interface CSTWeekViewController : UIViewController <UIDocumentInteractionControllerDelegate>

{

    
    NSArray *expandedWeeks;
    VideoTarget1 target;
    NSMutableDictionary *downloadButtons;
    NSMutableDictionary *resourceButtons;
    NSMutableDictionary *accessoryViews;
    NSMutableDictionary *completedButtons;
    CourseraPlayerManager *videoProcessingManager;
    CourseraPlayerManager *subtitleProcessingManager;
    NSMutableDictionary *operations;
    int numberOfCompletedCourses;
    YouTubeURLManager *youtubeURLManager;
    NSMutableDictionary *completedButtonStates;
    UIPopoverController *resourcePopover;
    ResourceDownloadViewController *resourceDownloadViewController;
}


@property (retain, nonatomic) LectureViewController *lectureViewController;

@property (weak, nonatomic) IBOutlet UIImageView *courseImage;

@property (weak, nonatomic) IBOutlet UILabel *courseTitleLb;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *courseUniverLb;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *courseDescLb;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *courseDescLb2;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *courseDescNuberCoursesLbl;

@property (weak, nonatomic) IBOutlet UILabel *courseProviderLb;
@property (weak, nonatomic) IBOutlet UIImageView *courseProviderBG;

@property (weak, nonatomic) IBOutlet TTTAttributedLabel *courseUniversityLb;

@property (weak, nonatomic) IBOutlet UITableView *tableWeek;
@property (weak, nonatomic) IBOutlet UIButton *courseWebBtn;
- (IBAction)courseWebBtnPressed:(id)sender;




//array of weeks
@property (nonatomic, strong) NSArray *weeks;
//
//selected course
@property (nonatomic, strong) NSDictionary *selectedCourse;
@property (nonatomic, weak) NSString *providerName;
//

@property(nonatomic,assign) id<IProviderService> service;

@property (weak, nonatomic) IBOutlet DCRoundSwitch *switchArchivedRound;

@property (weak, nonatomic) IBOutlet UIImageView *angleCut;
@property (retain, nonatomic) MCProgressBarView *progressBarWeek;
@property (retain, nonatomic) IBOutlet UIImageView *backgroundFill;
@property int currentScienceBranchNum;
@property NSString  *courseBranchName;
@property (weak, nonatomic) IBOutlet UITextView *noSavedLecturesTxt;

@property (strong, nonatomic) WebViewController *webViewController;

- (void) configureGlobalDownloadView;

-(void)setCompletedButtonAfterVideoFinished;

- (IBAction)deleteAll;

@end
