//
//  LectureViewController.h
//  Coursistant Sceleton
//
//  Created by Andrew on 25.04.13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "CSTCommonBarButton.h"
#import "LectureSpeedViewController.h"
#import "DownloadItem.h"
#import "WebViewController.h"

#ifndef LITE_VERSION
#import "SubtitleView.h"
#import "SubRip.h"
#endif

#import "LanguageViewController.h"

@interface LectureViewController : UIViewController <UIPopoverControllerDelegate, UIGestureRecognizerDelegate> {
    
    UIActivityIndicatorView *activityIndicator;
    MPMoviePlayerController *moviePlayerController;
#ifndef LITE_VERSION
    SubtitleView *subtitleView;
    SubRip *subRip;
#endif
    NSTimer *subtitleTimer;
    NSTimer *quizTimer;
    BOOL fullscreen;
    CSTCommonBarButton *subtitleButton;
    CSTCommonBarButton *speedButton;
    LectureSpeedViewController *lectureSpeedViewController;
    UIPopoverController *popover;
    NSArray *quizes;
    WebViewController *webViewController;
    NSTimeInterval lastQuizTime;
    UITextView *quizMessageView;
    CGPoint startPosition ;
    UITapGestureRecognizer *tapGestureRecognizer;
    UIPanGestureRecognizer *panGesture;
    UIPopoverController *languagePopover;

    LanguageViewController *languageViewController;
    UIPopoverController *languagePopoverController;
    NSString *subPath;
}

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSString *quizCode;
@property (nonatomic, strong) NSArray *subtitles;
@property (nonatomic, strong) NSString *subPath;
@property (nonatomic, strong) DownloadItem*lectureDownloadItem;

@end
