//
//  LectureViewController.m
//  Coursistant Sceleton
//
//  Created by Andrew on 25.04.13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import "LectureViewController.h"
#import "OfflineDataManager.h"
#import "CSTWeekViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "DownloadControlBackgroundView.h"
#import "AlertViewBlocks.h"
#import "DownloadManager.h"
#import "JSParser.h"
#import "LanguageViewController.h"
#import <EXTScope.h>
#import "DownloadItemHelper.h"
#import "SettingsHelper.h"
#import "CoursistantIAPHelper.h"


@interface LectureViewController ()

@end

@implementation LectureViewController

@synthesize url;
@synthesize quizCode;
@synthesize subPath;

- (id) init {
    self = [super init];
    
    return self;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    if (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        return NO;
    }
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
    
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    speedButton = [[CSTCommonBarButton alloc] initWithNormalTitle:@"Speed: 1.0x" andSelectedTitle:@"Speed: 1.0x"];
    speedButton.selected = NO;
    UIBarButtonItem *speedBarButton = [[UIBarButtonItem alloc] initWithCustomView:speedButton];
    
    lectureSpeedViewController = [[LectureSpeedViewController alloc] initWithNibName:@"LectureSpeedViewController" bundle:nil];
    popover = [[UIPopoverController alloc] initWithContentViewController:lectureSpeedViewController];
    popover.popoverContentSize = CGSizeMake(215, 85);
    popover.popoverBackgroundViewClass = [DownloadControlBackgroundView class];
    popover.delegate = self;
    
    __block UIPopoverController *blockPopover = popover;
    speedButton.stateTrackingBlock = ^(BOOL state) {
        if(state) {
            [blockPopover presentPopoverFromBarButtonItem:speedBarButton permittedArrowDirections:UIPopoverArrowDirectionUp animated:NO];
            
        } else {
            [blockPopover dismissPopoverAnimated:NO];
        }
        
    };
    
    subtitleButton = [[CSTCommonBarButton alloc] initWithNormalTitle:@"Subtitles: OFF" andSelectedTitle:@"Subtitles: ON"];
    subtitleButton.selected = NO;
    UIBarButtonItem *subtitleBarButton = [[UIBarButtonItem alloc] initWithCustomView:subtitleButton];
    
    __block UIButton *blockSubtitleButton = subtitleButton;
#ifndef LITE_VERSION
    
    languageViewController = [[LanguageViewController alloc] initWithNibName:@"LanguageViewController" bundle:nil];
    languagePopoverController = [[UIPopoverController alloc] initWithContentViewController:languageViewController];
    languagePopoverController.popoverBackgroundViewClass = [DownloadControlBackgroundView class];
    languagePopoverController.delegate = self;
    languageViewController.popover = languagePopoverController;
    
    subtitleView = [[SubtitleView alloc] init];
    __block UIPopoverController *lpc = languagePopoverController;
    
    @weakify(self)
    subtitleButton.stateTrackingBlock = ^(BOOL state) {
        
        @strongify(self);
        if(state) {
            if(self.subtitles != nil) {
                if([[CoursistantIAPHelper sharedInstance] isAllLanguagesAvailable]) {
                    lpc.popoverContentSize = CGSizeMake(320, 170);
                } else {
                    lpc.popoverContentSize = CGSizeMake(320, 270);
                }
                [lpc presentPopoverFromBarButtonItem:subtitleBarButton permittedArrowDirections:UIPopoverArrowDirectionUp animated:NO];
            } else {
                UIAlertView *alert =[[UIAlertView alloc] initWithTitle:nil message:@"Subtitles are not available for this lecture" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
                [alert showAlerViewFromButtonAction:nil animated:NO handler:nil];
                blockSubtitleButton.selected = NO;
            }
        } else {
            [lpc dismissPopoverAnimated:NO];
            [self switchSubtitlesOff];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"defaultLanguage"];
        }
    };
#else
    subtitleButton.stateTrackingBlock = ^(BOOL state) {
        
        UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"Premium functionality"
                                                       message:@"To enable subtitles you can get the full version of Coursistant app."
                                                      delegate:nil
                                             cancelButtonTitle:@"No, thanks"
                                             otherButtonTitles:@"Full Version", nil];
        
        [alert showAlerViewFromButtonAction:nil
                                   animated:YES
                                    handler:^(UIAlertView *alertView, NSInteger buttonIndex){
                                        if(buttonIndex == 1) {
                                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/coursistant/id681213120?mt=8&uo=4"]];
                                        }
                                        blockSubtitleButton.selected = NO;
                                    }];
    };
    
#endif
    
    webViewController = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil];
    webViewController.resourceURL = nil;
    
    lastQuizTime = 0;

    if (aboveIOS61) {
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                           initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                           target:nil action:nil];
        negativeSpacer.width = -10;
        
        
        self.navigationItem.rightBarButtonItems = @[negativeSpacer, speedBarButton, [[UIBarButtonItem alloc] initWithCustomView:subtitleButton]];
    } else
    self.navigationItem.rightBarButtonItems = @[speedBarButton, [[UIBarButtonItem alloc] initWithCustomView:subtitleButton]];
}



- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (!moviePlayerController.fullscreen) {
        moviePlayerController = [[MPMoviePlayerController alloc] init];
        moviePlayerController.currentPlaybackRate = lectureSpeedViewController.speed;
        __block MPMoviePlayerController *blockMoviePlayerController = moviePlayerController;
        __block CSTCommonBarButton *blockSpeedButton = speedButton;
        lectureSpeedViewController.speedTrackingBlock = ^(float speed) {
            blockMoviePlayerController.currentPlaybackRate = speed;
            NSString *speedStr = [[NSString alloc] initWithFormat:@"Speed: %1.2fx", speed];
            [blockSpeedButton setTitle:speedStr forState:UIControlStateNormal];
            [blockSpeedButton setTitle:speedStr forState:UIControlStateSelected];
        };
        
        moviePlayerController.controlStyle = MPMovieControlStyleDefault;
        //moviePlayerController.repeatMode = MPMovieRepeatModeOne;
        moviePlayerController.movieSourceType = MPMovieSourceTypeUnknown;
        moviePlayerController.scalingMode = MPMovieScalingModeAspectFit;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(moviePlayerDidEnterFullscreen)
                                                     name:MPMoviePlayerDidEnterFullscreenNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(moviePlayerDidExitFullscreen)
                                                     name:MPMoviePlayerDidExitFullscreenNotification
                                                   object:nil];
        
        // 4 - Register for the playback finished notification
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(movieFinishedCallback:)
                                                     name:MPMoviePlayerPlaybackDidFinishNotification
                                                   object:moviePlayerController];
        
        activityIndicator.center = self.view.center;
        [self.view addSubview:activityIndicator];
        [activityIndicator startAnimating];
    }
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"in_video_quiz_full"] && (quizCode != nil) && (lastQuizTime == 0)) {
        NSDictionary *quizesJSON = [NSJSONSerialization JSONObjectWithData:[[JSParser filterUnsafeJSON:quizCode] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
        quizes = [quizesJSON objectForKey:@"data"];
        if(quizes) {
            [self switchQuiz:YES];
        }
    }
    

#ifndef LITE_VERSION

    
    [self updateSubPath];

    // Language View Setup
    [self setupLanguageViewController];
    
    // Subtitle Button Setup
    [self setupSubtitleButton];

#endif
}


- (void) viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    if (!moviePlayerController.fullscreen) {
        
        //NSString *stringUrl = [[url absoluteString] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        //[moviePlayerController setContentURL:[NSURL URLWithString:stringUrl]];
        [moviePlayerController setContentURL:url];
        [moviePlayerController prepareToPlay];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(moviePlayerLoadStateChanged:)
                                                     name:MPMoviePlayerLoadStateDidChangeNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(moviePlayerPlaybackStateDidChange:)
                                                     name:MPMoviePlayerPlaybackStateDidChangeNotification
                                                   object:nil];

    }
}

- (void)moviePlayerPlaybackStateDidChange:(NSNotification *)notif
{
    if (moviePlayerController.playbackState == MPMoviePlaybackStatePlaying){
        
        moviePlayerController.currentPlaybackRate = lectureSpeedViewController.speed;
        if(lastQuizTime > 0) {
            lastQuizTime = lastQuizTime+1.0f;
            [moviePlayerController setCurrentPlaybackTime:(lastQuizTime)];
            [self switchQuiz:YES];
        }
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:MPMoviePlayerPlaybackStateDidChangeNotification
                                                      object:nil];
        [moviePlayerController play];
        if(quizCode != nil) {
            if(quizMessageView == nil) {
                [self createQuizMessageView];
            }
            if([[NSUserDefaults standardUserDefaults] boolForKey:@"in_video_quiz_full"]) {
                
                if([self nextQuizTimeLabel]) {
                    [self showQuizMessageView:[self nextQuizTimeLabel]];
                }
            } else {
                [self showQuizTeaser];
            }
        }
    }
//    else if (moviePlayerController.playbackState == MPMoviePlaybackStatePaused){
//        lectureSpeedViewController.speed=1;
//        
//    }

}

- (void)moviePlayerLoadStateChanged:(NSNotification *)notif
{
    if (moviePlayerController.loadState & MPMovieLoadStateStalled) {
        //        [activityIndicator startAnimating];
        [moviePlayerController pause];
    } else if (moviePlayerController.loadState & MPMovieLoadStatePlaythroughOK) {
        //        [activityIndicator stopAnimating];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:MPMoviePlayerLoadStateDidChangeNotification
                                                      object:nil];
        moviePlayerController.view.frame = self.view.bounds;
        [self.view addSubview:moviePlayerController.view];
        
 
/////gesture recognizers
        BOOL aboveIOS61 = kCFCoreFoundationVersionNumber > kCFCoreFoundationVersionNumber_iOS_6_1;
        if (aboveIOS61) {
            
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"video_gesture_tap_pause_full"]) {
                tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
                [tapGestureRecognizer setDelegate:self];
                
                tapGestureRecognizer.numberOfTapsRequired = 1;
                [moviePlayerController.view addGestureRecognizer:tapGestureRecognizer];
            }
            
            //http://www.danielhanly.com/blog/tutorial/gesture-controlling-a-video-with-mpmovieplayercontroller/
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"video_gesture_tap_drag_rewind_full"]) {
                
                panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
                [self.view addGestureRecognizer:panGesture];
            }
        }
/////
        
        
#ifndef LITE_VERSION
        if([SettingsHelper isDefaultLanguageDefined]) {
            [self switchSubtitlesOn];
        }
#endif
        
    }
    
}


- (void) viewWillDisappear:(BOOL)animated {
    
    if (!moviePlayerController.fullscreen) {
        if(moviePlayerController != nil){
            [self playerShutdown];
        }
#ifndef LITE_VERSION
        [self switchSubtitlesOff];
        [self switchQuiz:NO];
#endif
    }
    [activityIndicator removeFromSuperview];
    [self hideQuizMessageView];
    
    [moviePlayerController.view removeGestureRecognizer:tapGestureRecognizer];
    [self.view removeGestureRecognizer:panGesture];
    [languagePopoverController dismissPopoverAnimated:NO];
    
    [super viewWillDisappear:animated];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)movieFinishedCallback:(NSNotification*)aNotification {
    
    CSTWeekViewController *weekVC = [[[self navigationController] viewControllers] objectAtIndex:1] ;
    [weekVC setCompletedButtonAfterVideoFinished];
    if (moviePlayerController.fullscreen) {
        moviePlayerController.fullscreen = NO;
    }
    [self goBack];
}

-(void)moviePlayerDidEnterFullscreen {
    fullscreen = YES;

    
#ifndef LITE_VERSION

    if(subtitleView.superview != nil) {
        [subtitleView removeFromSuperview];
    }
    BOOL aboveIOS61 = kCFCoreFoundationVersionNumber > kCFCoreFoundationVersionNumber_iOS_6_1;
    if (aboveIOS61) {
    
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"video_gesture_tap_pause_full"] || [[NSUserDefaults standardUserDefaults] boolForKey:@"video_gesture_tap_drag_rewind_full"]) {
            UIWindow *window = [[UIApplication sharedApplication].windows objectAtIndex:0];
            UIView * videoView = [[window subviews] lastObject];
            
            UIView *aView = [[UIView alloc] initWithFrame:videoView.bounds];
            aView.tag = 500;
            
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"video_gesture_tap_pause_full"]) {
                tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
                [tapGestureRecognizer setDelegate:self];
                
                tapGestureRecognizer.numberOfTapsRequired = 1;
                [aView addGestureRecognizer:tapGestureRecognizer];
                
            }
            
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"video_gesture_tap_drag_rewind_full"]) {
                panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                     action:@selector(handlePanGesture:)];
                [aView addGestureRecognizer:panGesture];
            }
            
            
            [videoView addSubview:aView];
        }

    }
#endif

}

-(void)moviePlayerDidExitFullscreen {
    fullscreen = NO;
#ifndef LITE_VERSION
    if(subtitleView.superview != nil) {
        [subtitleView removeFromSuperview];
    }
    [[self.view viewWithTag:500] removeGestureRecognizer:tapGestureRecognizer];
    [[self.view viewWithTag:500] removeGestureRecognizer:panGesture];
    [[self.view viewWithTag:500] removeFromSuperview];
#endif
    

}


-(void)goBack{
    if (moviePlayerController.loadState & MPMovieLoadStateStalled){
        [self playerShutdown];
    }
    [popover dismissPopoverAnimated:NO];
    [[self navigationController] popViewControllerAnimated:YES];
    subPath = nil;
    lastQuizTime = 0;
}

-(void)playerShutdown{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerDidEnterFullscreenNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerDidExitFullscreenNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerLoadStateDidChangeNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackStateDidChangeNotification
                                                  object:nil];   
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMovieDurationAvailableNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:nil
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [moviePlayerController pause];
    moviePlayerController.initialPlaybackTime = -1;
    
    if(!moviePlayerController.fullscreen) {
        moviePlayerController.initialPlaybackTime = moviePlayerController.duration;
        [moviePlayerController stop];
        [moviePlayerController.view removeFromSuperview];
        moviePlayerController.contentURL = nil;
        moviePlayerController = nil;
    }
    //    [activityIndicator removeFromSuperview];
    
}

#ifndef LITE_VERSION

-(void) updateSubPath {
    
    if([SettingsHelper isDefaultLanguageDefined]) {
        NSString *defaultLanguage = [SettingsHelper defaultLanguage];
        DownloadItem *stub = [DownloadItemHelper createSubtitleDownloadItemStub:defaultLanguage stencil:self.lectureDownloadItem];
        subPath = [DownloadManager filePath:stub];
        if([@"en" isEqualToString:defaultLanguage] && ![[NSFileManager defaultManager] fileExistsAtPath:subPath]) {
            
            subPath = [subPath stringByReplacingOccurrencesOfString:@".en" withString:@""];
            if(![[NSFileManager defaultManager] fileExistsAtPath:subPath]) {
                subPath = nil;
            }
        }
    }
}

-(void) setupSubtitleButton {
    if([SettingsHelper isDefaultLanguageDefined]) {
        NSString *defaultLanguage = [SettingsHelper defaultLanguage];
        
        subtitleButton.selected = YES;
        NSString *buttonTitle = [@"Subtitles: " stringByAppendingString:[[defaultLanguage uppercaseString] substringToIndex:2]];
        [subtitleButton setTitle:buttonTitle forState:UIControlStateSelected];
    } else {
        subtitleButton.selected = NO;
        NSString *buttonTitle = @"Subtitles: OFF";
        [subtitleButton setTitle:buttonTitle forState:UIControlStateNormal];
    }
}

-(void) setupLanguageViewController {
    if(self.subtitles != nil) {
        languageViewController.subtitles = self.subtitles;
        languageViewController.downloadItem = self.lectureDownloadItem;
        __block UIButton *blockSubtitleButton = subtitleButton;
        @weakify(self)
        languageViewController.languageTrackingBlock = ^(NSString *code, NSString *languageFile) {
            @strongify(self)
            if(code != nil) {
                [self switchSubtitlesOff];
                NSString *buttonTitle = [@"Subtitles: " stringByAppendingString:[code uppercaseString]];
                [blockSubtitleButton setTitle:buttonTitle forState:UIControlStateSelected];
                self.subPath = languageFile;
                [self switchSubtitlesOn];
                [[NSUserDefaults standardUserDefaults] setObject:code forKey:@"defaultLanguage"];
            } else {
                blockSubtitleButton.selected = NO;
            }
        };
    }
}

-(void) refreshSubtitles {
    NSTimeInterval currentTime = moviePlayerController.currentPlaybackTime;
    
    NSUInteger i = [subRip indexOfSubRipItemForPointInTime:CMTimeMake(currentTime, 1)];
    
    if(i < subRip.subtitleItems.count) {
        if(subtitleView.superview == nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(fullscreen) {
                    [subtitleView addToVideoView];
                } else {
                    [subtitleView addToViewController:self];
                }
            });
        }
        
        SubRipItem *subtitle = [subRip.subtitleItems objectAtIndex:i];
        if(![subtitleView.text isEqualToString:subtitle.text]) {
            subtitleView.text = subtitle.text;
        }
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            subtitleView.text = @"";
            [subtitleView removeFromSuperview];
        });
    }
}

-(void) switchSubtitlesOn {
    subRip = [[SubRip alloc] initWithFile:subPath];
    if(subRip != nil) {
        if(!subtitleTimer && (moviePlayerController.loadState & MPMovieLoadStatePlaythroughOK)) {
            subtitleTimer = [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(refreshSubtitles) userInfo:nil repeats:YES];
        }
    } else {
        [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(switchSubtitlesOn)userInfo:nil repeats:NO];
    }
}

-(void) switchSubtitlesOff {
    if(subtitleTimer) {
        [subtitleTimer invalidate];
        subtitleTimer = nil;
    }
    if(subtitleView.superview != nil) {
        [subtitleView removeFromSuperview];
        
    }
}


#endif

-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    speedButton.selected = NO;
}

-(void) switchQuiz:(BOOL)on {
    if(on) {
        if(!quizTimer) {
            quizTimer = [NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(checkQuiz) userInfo:nil repeats:YES];
        }
    } else {
        if(quizTimer) {
            [quizTimer invalidate];
            quizTimer = nil;
        }
    }
}

-(void) checkQuiz {
    NSTimeInterval currentTime = moviePlayerController.currentPlaybackTime;
    
    NSInteger quizIndex = [self quizIndexForTime:currentTime];
    if(quizIndex >= 0 && currentTime > lastQuizTime) {
        lastQuizTime = moviePlayerController.currentPlaybackTime;
        webViewController.title = @"In-video Quiz";
        webViewController.html = [self createQuizHTML:quizIndex];
        [self.navigationController pushViewController:webViewController animated:YES];
        [self switchQuiz:NO];
    }
}

-(NSString *) createQuizHTML:(NSInteger)quizIndex {
    NSDictionary *quiz = [quizes objectAtIndex:quizIndex];
    NSString *head = [[NSString alloc] initWithFormat:@"<html><head><title></title><script>%@</script></head><body><form action=\"%@\" method=\"post\">", [WebViewController callJS], [quiz valueForKey:@"post_answer_url"]];
    NSString *body = [quiz valueForKey:@"html"];
    NSString *footer = [[NSString alloc] initWithFormat:@"%@<input type=\"hidden\" name=\"attempt_number\" value=\"1\"></form></body></html>", [LectureViewController quizButtons:body]];
    return [[head stringByAppendingString:body] stringByAppendingString:footer];
}

+(NSString *) quizButtons:(NSString *)quizCode {
    NSString *buttons = @"<input type=\"button\" value=\"Continue\" style=\"position:absolute; left:40px; top:580px;\" onclick=\"call('goBack');\" />";
    if([quizCode rangeOfString:@"input"].location != NSNotFound) {
        buttons = [buttons stringByAppendingString:@"<input type=\"submit\" style=\"position:absolute; left:120px; top:580px;\" value=\"Submit\" />"];
    }
    return buttons;
}

-(NSInteger)quizIndexForTime:(NSTimeInterval)currentTime {
    for(int i = 0; i < quizes.count; i++) {
        NSDictionary *quiz = [quizes objectAtIndex:i];
        double quizTime = [[quiz objectForKey:@"time"] doubleValue];
        if((currentTime >= quizTime - 0.5f) && (currentTime <= quizTime + 0.5f)) {
            return i;
        }
    }
    return -1;
}

-(NSString*)nextQuizTimeLabel {
    for(int i = 0; i < quizes.count; i++) {
        NSDictionary *quiz = [quizes objectAtIndex:i];
        NSDecimalNumber *quizTime = [NSDecimalNumber decimalNumberWithDecimal:[[quiz objectForKey:@"time"] decimalValue]];
        if(lastQuizTime <= [quizTime doubleValue]) {
            int minutes = [[quizTime decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithInt:60] decimalValue]]] intValue];
            int seconds = [quizTime intValue] - minutes*60;
            return [[NSString alloc] initWithFormat:@"%dm:%ds", minutes, seconds];
        }
    }
    return nil;
}

-(void) createQuizMessageView {
    int x = 0;
    int y = 0;
    quizMessageView = [[UITextView alloc] initWithFrame:CGRectMake(x, y, 300, 50)];
    quizMessageView.userInteractionEnabled = NO;
    quizMessageView.textColor = [UIColor whiteColor];
    quizMessageView.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.3f];
    quizMessageView.font = [UIFont fontWithName:@"Helvetica-Bold" size:14.0f];
    quizMessageView.textAlignment = NSTextAlignmentCenter;
}

-(void) showQuizMessageView:(NSString *)quizTimeLabel {
    quizMessageView.text = [[NSString alloc] initWithFormat:@"In-video quiz in: %@", quizTimeLabel];
    [self.view addSubview:quizMessageView];
    [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(hideQuizMessageView) userInfo:nil repeats:NO];
}

-(void) hideQuizMessageView {
    if(quizMessageView != nil) {
        [quizMessageView removeFromSuperview];
    }
}

-(void) showQuizTeaser {
    quizMessageView.text = @"This lecture contains in-video quiz.\nEnable it in Settings to pass.";
    [self.view addSubview:quizMessageView];
    [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(hideQuizMessageView) userInfo:nil repeats:NO];
}

#pragma mark - gesture delegate
// this allows you to dispatch touches
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return YES;
}
// this enables you to handle multiple recognizers on single view
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

-(void)handleTapGesture:(UITapGestureRecognizer*)sender{
    if (moviePlayerController.playbackState == MPMoviePlaybackStatePaused){
        [moviePlayerController play];
    } else if (moviePlayerController.playbackState == MPMoviePlaybackStatePlaying){
        [moviePlayerController pause];
    }
 }


- (void) handlePanGesture:(UIPanGestureRecognizer*)pan{
    
//    if (moviePlayerController.playbackState == MPMoviePlaybackStatePlaying){
//        [moviePlayerController pause];
//    }

    if(pan.state == UIGestureRecognizerStateEnded){
        moviePlayerController.currentPlaybackRate = lectureSpeedViewController.speed;
    } else {
        UIWindow *window = [[UIApplication sharedApplication].windows objectAtIndex:0];
        UIView * videoView = [[window subviews] lastObject];
        CGPoint velocity = [pan velocityInView:videoView];
        CGFloat xVel = velocity.x;
        int i = xVel*100;
        CGFloat rate = i/10000;
        moviePlayerController.currentPlaybackRate = rate;
    }
}
@end
