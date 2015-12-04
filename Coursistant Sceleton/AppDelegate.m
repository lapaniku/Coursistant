//
//  AppDelegate.m
//  Coursistant Sceleton
//
//  Created by Andrew on 19.12.12.
//  Copyright (c) 2012 Andrew. All rights reserved.
//

#import "AppDelegate.h"


#import "AFHTTPRequestOperationLogger.h"

#import "UIImage+iPhone5.h"


#import "OfflineDataManager.h"
#import "StartScreenViewController.h"
#import "CSTDownloadControlButton.h"

#import "SSKeychain.h"
#import "Appirater.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "AVFoundation/AVAudioSession.h"
#import "ParserManager.h"
#import "Flurry.h"
#import "CoursistantIAPHelper.h"


@implementation AppDelegate
//@synthesize loginViewController,detailViewController,leftController,deckController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    [CoursistantIAPHelper sharedInstance];
    [[OfflineDataManager sharedOfflineDataManager] startTracking];
    
    //[[AFHTTPRequestOperationLogger sharedLogger] startLogging];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    

    
    
    
    CSTLoginViewController *loginViewController = [[CSTLoginViewController alloc] initWithNibName:@"CSTLoginViewController" bundle:nil];
    CSTDetailViewController *detailViewController = [[CSTDetailViewController alloc] initWithNibName:@"CSTDetailViewController" bundle:nil];
    loginViewController.detailViewController = detailViewController;

    StartScreenViewController *startScreenViewController = [[StartScreenViewController alloc] initWithNibName:@"StartScreenViewController" bundle:nil];
    startScreenViewController.detailViewController = detailViewController;
    startScreenViewController.loginViewController = loginViewController;
    
    CSTSettingsViewController*settingsViewController = [[CSTSettingsViewController alloc] init];
    
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:detailViewController];
    [self.navigationController pushViewController:startScreenViewController animated:NO];
    

    [self customizeAppearance];


        
//   self.window.rootViewController = self.navigationController;
    
    
    
    //////
    CSTSideViewController *leftController = [[CSTSideViewController alloc] initWithNibName:@"CSTSideViewController" bundle:nil];
    leftController.detailViewController=detailViewController;
    leftController.loginController = loginViewController;
    leftController.appSettingsViewController = settingsViewController;

  
    IIViewDeckController *deckController =  [[IIViewDeckController alloc] initWithCenterViewController:self.navigationController
                                                                                    leftViewController:leftController
                                                                                   rightViewController:nil];
    
    //deckController.rightSize = 500;
    deckController.leftSize = 910;
    
    /* To adjust speed of open/close animations, set either of these two properties. */
    deckController.openSlideAnimationDuration = 0.15f;
    deckController.closeSlideAnimationDuration = 0.25f;
    
    
    self.window.rootViewController = deckController;
    //self.window.rootViewController = self.navigationController;
  
    //////
    //NSArray *accountsCoursera = [[NSArray alloc]  initWithArray:[SSKeychain accountsForService:@"CourseraSuccessLogin"]];
    //Clear keychain on first run in case of reinstallation
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"FirstRun"]) {
        // Delete values from keychain here
        NSArray *accountsCoursera = [[NSArray alloc]  initWithArray:[SSKeychain accountsForService:@"CourseraSuccessLogin"]];
        if (accountsCoursera) {
            for (NSDictionary *user in accountsCoursera) {
                [SSKeychain deletePasswordForService:@"CourseraSuccessLogin" account:[user valueForKey:kSSKeychainAccountKey]];

            }
        }
        
        NSArray *accountsUda = [[NSArray alloc]  initWithArray:[SSKeychain accountsForService:@"UdacitySuccessLogin"]];
        if (accountsUda) {
            for (NSDictionary *user in accountsUda) {
                [SSKeychain deletePasswordForService:@"UdacitySuccessLogin" account:[user valueForKey:kSSKeychainAccountKey]];
            }
        }

    }
    

    [Flurry setCrashReportingEnabled:YES];
    
#ifdef LITE_VERSION

    // Load the default values for the user defaults
    NSString* pathToUserDefaultsValues = [[NSBundle mainBundle]
                                          pathForResource:@"userDefaultsLite"
                                          ofType:@"plist"];
    NSDictionary* userDefaultsValues = [NSDictionary dictionaryWithContentsOfFile:pathToUserDefaultsValues];
    // Set them in the standard user defaults
    [[NSUserDefaults standardUserDefaults] registerDefaults:userDefaultsValues];
    
    
    [Flurry startSession:@"R3T5X38TXH9FXVTP8X4S"];
   
    [Appirater setAppId:@"689386132"];
    
//    [Appsee start:@"4fdd3cb20bcb4be391d3be77dcdcd561"];

#else
    // Load the default values for the user defaults
    NSString* pathToUserDefaultsValues = [[NSBundle mainBundle]
                                          pathForResource:@"userDefaultsFull"
                                          ofType:@"plist"];
    NSDictionary* userDefaultsValues = [NSDictionary dictionaryWithContentsOfFile:pathToUserDefaultsValues];
    // Set them in the standard user defaults
    [[NSUserDefaults standardUserDefaults] registerDefaults:userDefaultsValues];
    
    [Flurry startSession:@"C643QGSWCJ7YY8VXNTGK"];
    
    [Appirater setAppId:@"681213120"];
    
#endif
    
    [Flurry logAllPageViews:self.navigationController];
    
    /////appirater
    [Appirater setDaysUntilPrompt:7];
    [Appirater setUsesUntilPrompt:15];
    [Appirater setSignificantEventsUntilPrompt:-1];
    [Appirater setTimeBeforeReminding:15];
    [Appirater setDebug:NO];
    [Appirater appLaunched:YES];
    /////
    

    
    [self.window makeKeyAndVisible];
    
    return YES;
    
}

-(void) customizeAppearance	{
    
     [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    UIImage *navBarImage = [UIImage imageNamed:@"navbar.png"];
    
    [[UINavigationBar appearance] setBackgroundImage:navBarImage forBarMetrics:UIBarMetricsDefault];
//    [[UINavigationBar appearance] setTitleTextAttributes:
//     [NSDictionary dictionaryWithObjectsAndKeys:
//      [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0],
//      UITextAttributeTextColor,
//      [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8],
//      UITextAttributeTextShadowColor,
//      /*[NSValue valueWithUIOffset:UIOffsetMake(0, -1)]*/nil,
//      UITextAttributeTextShadowOffset,
//      nil]];
    NSDictionary *titleTextAttrDic = [[NSDictionary alloc] initWithObjectsAndKeys:
    [UIColor colorWithRed:150.0/255.0 green:150.0/255.0 blue:150.0/255.0 alpha:0.8],
    UITextAttributeTextColor,
    /*[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8],
     UITextAttributeTextShadowColor,
     [NSValue valueWithUIOffset:UIOffsetMake(0, -1)],
     UITextAttributeTextShadowOffset,*/
    [UIFont fontWithName:@"HelveticaNeue-Bold" size:0.0],
    UITextAttributeFont,
    nil];
   
    
    [[UINavigationBar appearance] setTitleTextAttributes: titleTextAttrDic];
    
//    UIImage *minImage = [UIImage tallImageNamed:@"ipad-slider-fill"];
//    UIImage *maxImage = [UIImage tallImageNamed:@"ipad-slider-track.png"];
//    UIImage *thumbImage = [UIImage tallImageNamed:@"ipad-slider-handle.png"];
//    
//    [[UISlider appearance] setMaximumTrackImage:maxImage forState:UIControlStateNormal];
//    [[UISlider appearance] setMinimumTrackImage:minImage forState:UIControlStateNormal];
//    [[UISlider appearance] setThumbImage:thumbImage forState:UIControlStateNormal];
//    [[UISlider appearance] setThumbImage:thumbImage forState:UIControlStateHighlighted];
    
    //UIGraphicsBeginImageContextWithOptions(CGSizeMake(30, 30), NO, 0.0);
    //UIImage *blank = UIGraphicsGetImageFromCurrentImageContext();
    //UIGraphicsEndImageContext();
    //UIImage *barItemImage = [[UIImage tallImageNamed:@"side_pannel_button_bkg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
    
    //UIImage *barItemImage = [blank resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
    //[[UIBarButtonItem appearance] setBackgroundImage:barItemImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    //[[UIBarButtonItem appearance] setTintColor:[UIColor blackColor]];
    
//    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
//                                [UIColor colorWithRed:61.0/255.0 green:174.0/255 blue:211.0/255.0 alpha:1.0],UITextAttributeTextColor,
//                                [NSValue valueWithCGSize:CGSizeMake(0.0,0.0)],UITextAttributeTextShadowOffset,
//                                nil];
    
    //[[UIBarButtonItem appearance] setTitleTextAttributes:attributes
    //                                            forState:UIControlStateNormal];


   

    
    //UIImage *backButton = [[UIImage tallImageNamed:@"ipad-back.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 14, 0, 4)];
    //[[UIBarButtonItem appearance] setBackButtonBackgroundImage:barItemImage forState:UIControlStateNormal                                                 barMetrics:UIBarMetricsDefault];

    if ([self.navigationController.navigationBar respondsToSelector:@selector(setShadowImage:)]) {

    [[UINavigationBar appearance]setShadowImage:[[UIImage alloc] init]];

    }
    
    /////fix no audio in video
    AudioSessionInitialize(NULL, NULL, NULL, NULL);
    UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
    AudioSessionSetProperty(kAudioSessionProperty_AudioCategory,sizeof(sessionCategory), &sessionCategory);
    AudioSessionSetActive(YES);
    /////
    
    /////background playback
    NSError *setCategoryError = nil;
    [[AVAudioSession sharedInstance] setDelegate:self];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error: &setCategoryError];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    /////
    
    
}
- (void)applicationWillResignActive:(UIApplication *)application
{
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[ProgressDataManager sharedProgressDataManager] saveProgressData];
    [[ParserManager sharedParserManager] stopPeriodicUpdate];
    
//    __block UIBackgroundTaskIdentifier backgroundTaskIdentifier = [application beginBackgroundTaskWithExpirationHandler:^(void) {
//        [application endBackgroundTask:backgroundTaskIdentifier];
//        [[YourRestClient sharedClient] cancelAllHTTPOperations];
//    }];
    
//    UIApplication  *app = [UIApplication sharedApplication];
//    UIBackgroundTaskIdentifier bgTask;
//    
//    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
//        [app endBackgroundTask:bgTask];
//    }];
    

}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [Appirater appEnteredForeground:YES];
    [[ParserManager sharedParserManager] startPeriodicUpdate];

}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[ProgressDataManager sharedProgressDataManager] saveProgressData];
}

@end
