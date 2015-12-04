//
//  StartScreenViewController.m
//  Coursistant Sceleton
//
//  Created by Andrew on 12.04.13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import "StartScreenViewController.h"
#import "CourseraProviderService.h"

#import "UdacityProviderService.h"
#import "ILoginManager.h"
#import "OfflineDataManager.h"
#import "SSKeychain.h"
#import "ParserManager.h"
#import "AlertViewBlocks.h"
#import "DownloadManager.h"

@implementation StartScreenViewController

@synthesize loginViewController;
@synthesize detailViewController;
@synthesize courseraLabel, courseraActivity, udacityLabel, udacityActivity;

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
    [self.navigationController setNavigationBarHidden:YES];
    
    //self.bgImage.image = [UIImage imageNamed:@"start-screen-bg-gr.png"];
    self.repeatingTimer = [NSTimer scheduledTimerWithTimeInterval:0.6f
                                                           target:self
                                                         selector:@selector(updateWaves:)
                                                         userInfo:nil
                                                          repeats:YES];
    
    
    [self configureProviderLabels];
    
    //get current version
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
    
    //get saved version
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    if (defaults == nil || ![version isEqualToString:[defaults objectForKey:@"appVersion"]]) {
        
        NSString *title = [[NSString alloc] initWithFormat:@"New version %@!", version];
        NSString *message = [[NSString alloc] initWithFormat:@"Make sure you are usning Coursistant at full! Check settings to set features like:\nIn-video quiz\nPlayback gesture control\nResources (pdf,ppt) download\n\nJust added:\nInternational sutbitles for the full version - with minor fixes now"];
        UIAlertView *alert =[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"Great!" otherButtonTitles:nil];
        [alert show];

        
        [defaults setObject:version forKey:@"appVersion"];
    }
    

    
    delegateStack = [[DelegateStack alloc] init];
    ParserManager *pm = [ParserManager sharedParserManager];
    pm.delegate = self;
    [pm startPeriodicUpdate];
    [delegateStack useDelegate:@"parserManager"];
    
    self.versionLb.text = [@"v. " stringByAppendingString:[[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey]];
    #ifdef LITE_VERSION
    self.liteBg.hidden = NO;
    self.liteLb.hidden = NO;
    
    #endif
    
}

-(void) viewDidAppear:(BOOL)animated {
    
    //    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    //    for (NSHTTPCookie *cookie in cookies) {
    //        NSLog(@"--- %@\n",cookie);
    //    }
    [super viewDidAppear:animated];
    if([OfflineDataManager sharedOfflineDataManager].online) {
        if([self isAnySessionAvailableWithReload]) {
            if([delegateStack allDelegatesFree]) {
                [NSTimer scheduledTimerWithTimeInterval:4.0 target:self selector:@selector(showDetailViewByTimer:) userInfo:nil repeats:NO];
            }
        } else {
            // no valid sessions - go to login screen
            // add some explanation to login screen
            if([delegateStack allDelegatesFree]) {
                [NSTimer scheduledTimerWithTimeInterval:4.0 target:self selector:@selector(showLoginViewByTimer:) userInfo:@"You have no stored content yet, please add your credentials here to one of providers and press Login.\nYou can always sign up at the coursera.org udacity.com" repeats:NO];
            }
        }
    } else {
        if([self isAnyOfflineCoursesAvailable]) {
            [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(showDetailViewByTimer:) userInfo:nil repeats:NO];
        } else {
            [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(showLoginViewByTimer:) userInfo:@"You are working in offline mode and you have no stored course data. It could happen if you never open any of you profile or your authorization data was changed. Please, turn on your Internet connection and try to browse your profiles online." repeats:NO];
        }
    }
    
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"windowsFileConversion1"]) {
        [[DownloadManager sharedDownloadManager] convertDocFolderForWindows];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"windowsFileConversion1"];
    }
}

-(void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if ([self isViewLoaded] && [self.view window] == nil) {
        
        self.view = nil;
        
        [self.repeatingTimer invalidate];
        [self setRepeatingTimer:nil];
        
        [self setCourseraLabel:nil];
        [self setUdacityLabel:nil];
        [self setCourseraActivity:nil];
        [self setUdacityActivity:nil];
        [self setWaveImage:nil];
        [self setBgImage:nil];
        [self setLoginViewController:nil];
    }
}

- (void)updateWaves:(NSTimer *)theTimer {
    
    static int counter = 0;
    if( counter == 3 )
    {
        counter = 0;
    }
    NSString *imageWithCounter = [[NSString alloc] initWithFormat:@"wave%i.png",counter+1];
    self.waveImage.image = [UIImage imageNamed:imageWithCounter];
    [self.waveImage setNeedsDisplay];
    counter++;
    
}

- (void) configureProviderLabels {
    courseraLabel.hidden = YES;
    udacityLabel.hidden = YES;
    
    courseraActivity.hidden = YES;
    udacityActivity.hidden = YES;
}

- (void) startActivationOf:(NSString *)provider {
    UILabel *label;
    UIActivityIndicatorView *activity;
    
    if([provider isEqualToString:@"Coursera"]) {
        label = courseraLabel;
        activity = courseraActivity;
    } else if([provider isEqualToString:@"Udacity"]) {
        label = udacityLabel;
        activity = udacityActivity;
    }
    
    if(label != nil && activity != nil) {
        label.text = [provider stringByAppendingString:@" is activating"];
        [activity startAnimating];
        label.hidden = NO;
        activity.hidden = NO;
    }
}

- (void) stopActivationOf:(NSString *)provider {
    UILabel *label;
    UIActivityIndicatorView *activity;
    
    if([provider isEqualToString:@"Coursera"]) {
        label = courseraLabel;
        activity = courseraActivity;
    } else if([provider isEqualToString:@"Udacity"]) {
        label = udacityLabel;
        activity = udacityActivity;
    }
    
    if(label != nil && activity != nil) {
        label.text = [provider stringByAppendingString:@" is activated"];
        [activity stopAnimating];
        activity.hidden = YES;
    }
    
}

- (void) stopActiovationByTimer:(NSTimer *)timer
{
    NSString *provider = timer.userInfo;
    [self stopActivationOf:provider];
}

- (void) showDetailViewByTimer:(NSTimer *)timer
{
    [self showDetailView];
}

- (void) showLoginViewByTimer:(NSTimer *)timer
{
    NSString *message = timer.userInfo;
    [self showLoginView:message];
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

-(BOOL) isAnySessionAvailableWithReload {
    
    BOOL isAnySessionAvailable = NO;
    courseraLoginManager = [[CourseraProviderService sharedCourseraProviderService] loginManager:self];
    if([courseraLoginManager isSessionAlive]) {
        [self startActivationOf:@"Coursera"];
        
        [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(stopActiovationByTimer:) userInfo:@"Coursera" repeats:NO];
        
        isAnySessionAvailable = YES;
    } else {
        [self reloadSession:@"CourseraSuccessLogin" provider:@"Coursera" loginManager:courseraLoginManager];
    }
    
    udacityLoginManager = [[UdacityProviderService sharedUdacityProviderService] loginManager:self];
    //    if([udacityLoginManager isSessionAlive]) {
    //        [self startActivationOf:@"Udacity"];
    //
    //        [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(stopActiovationByTimer:) userInfo:@"Udacity" repeats:NO];
    //        isAnySessionAvailable = YES;
    //    } else {
    [self reloadSession:@"UdacitySuccessLogin" provider:@"Udacity" loginManager:udacityLoginManager];
    //    }
    return isAnySessionAvailable;
}

-(BOOL) isAnyOfflineCoursesAvailable {
    
    return [self isProfileFilled:@"Coursera"] || [self isProfileFilled:@"Udacity"];
}

- (void) loggedInSuccessfully:(NSString *)aUserID provider:(NSString *)provider {
    [delegateStack freeDelegate:provider];
    [self stopActivationOf:provider];
    [self showDetailViewIfNecessary];
}

- (void) loginErrorWithMessage:(NSString *)errorMessage provider:(NSString *)provider {
    [delegateStack freeDelegate:provider];
    
    if(errorMessage != nil) {
        NSString *title = [NSString stringWithFormat:@"%@ error", provider];
        NSString *message = [[NSString alloc] initWithFormat:@"The following error ocurred while login session refresh: %@", errorMessage];
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:nil otherButtonTitles:@"Open Settings", @"Open Courses", nil];
            [alertView show];
        });
    } else {
        NSString *title = [NSString stringWithFormat:@"%@ login error", provider];
        NSString *message = [[NSString alloc] initWithFormat:@"It seems some changes have been done recently with login process of %@. Let us know and we will make necessary app update to solve this problem. Though You can't temporarily access Your lectures online, You can try to use offline mode to browse downloaded data.", provider];
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:nil otherButtonTitles:@"Okay", nil];
            [alertView showAlerViewFromButtonAction:nil animated:YES handler:^(UIAlertView *alertView, NSInteger buttonIndex){
                if(buttonIndex == 0) {
                    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
                    if (mailClass != nil) {
                        if([mailClass canSendMail]) {
                            
                            NSString *emailTitle = @"Coursistant login problem";
                            // Email Content
                            NSString *messageBody = @"";
                            // To address
                            NSArray *toRecipents = [NSArray arrayWithObject:@"support@coursistant.com"];
                            
                            MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
                            mc.mailComposeDelegate = self;
                            
                            
                            [mc setSubject:emailTitle];
                            [mc setMessageBody:messageBody isHTML:YES];
                            [mc setToRecipients:toRecipents];
                            
                            [self presentViewController:mc animated:YES completion:NULL];
                        }
                    }
                }
            }];
        });
        
    }
}

- (void) loginProtocolError:(NSError *)error provider:(NSString *)provider {
    [delegateStack freeDelegate:provider];
    
    if(!errorDisplayed) {
        NSString *title = [NSString stringWithFormat:@"%@ error", provider];
        //    NSDictionary *userInfo = [error userInfo];
        //    NSString *errorMessage = [[userInfo objectForKey:NSUnderlyingErrorKey] localizedDescription];
        NSString *errorMessage = [error localizedDescription];
        NSString *message = [[NSString alloc] initWithFormat:@"The following error ocurred while login session refresh: %@", errorMessage];
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:nil otherButtonTitles:@"Open Settings", @"Open Courses", nil];
            [alertView show];
        });
        errorDisplayed = true;
    }
}

- (void) loginRedirected:(NSURLRequest *)request provider:(NSString *)provider {
    [delegateStack freeDelegate:provider];
    [self stopActivationOf:provider];
    [self showDetailViewIfNecessary];
}

-(BOOL) isAnySessionAvailable {
    
    if([[[CourseraProviderService sharedCourseraProviderService] loginManager:self] isSessionAlive]) {
        return YES;
    }
    
    if([[[UdacityProviderService sharedUdacityProviderService] loginManager:self] isSessionAlive]) {
        return YES;
    }
    return NO;
}


-(void) reloadSession:(NSString *)successCredentialsKey provider:(NSString *)provider loginManager:(id<ILoginManager>)loginManager {
    NSString *userName = [[[SSKeychain accountsForService:successCredentialsKey] lastObject] objectForKey:@"acct"];
    
    NSString *switchName = @"switch";
    switchName = [switchName stringByAppendingString:provider];
    
    BOOL state= [[NSUserDefaults standardUserDefaults] boolForKey:switchName];
    
    if (userName !=nil && state) {
        
        [delegateStack useDelegate:provider];
        [self startActivationOf:provider];
        [loginManager doLogin:userName password:[SSKeychain passwordForService:successCredentialsKey account:userName]];
    }
}

-(BOOL) isProfileFilled:(NSString *)providerName {
    NSArray *profile = [[OfflineDataManager sharedOfflineDataManager] profileFor:providerName];
    return ((profile != nil) && (profile.count > 0));
}

-(void) showDetailViewIfNecessary {
    if([delegateStack allDelegatesFree]) {
        if([self isAnySessionAvailable]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showDetailView];
            });
        } else {
            [self showLoginView:@"Please, verify your credentials here."];
        }
    }
}

-(void) showDetailView {
    //NSArray *viewControllers = [[NSArray alloc] initWithObjects: self.detailViewController, nil];
    //[self.navigationController setViewControllers:viewControllers animated:NO];
    [ParserManager sharedParserManager].delegate = nil;

    [self.navigationController popToRootViewControllerAnimated:NO];
    
}

-(void) showLoginView:(NSString *)message {
    
    // [self.navigationController popViewControllerAnimated:NO];
    // [self.navigationController pushViewController:self.loginViewController animated:NO];
    NSArray *viewControllers = [[NSArray alloc] initWithObjects: self.loginViewController, nil];
    [self.navigationController setViewControllers:viewControllers animated:NO];
    
    
    if(message != nil) {
        self.loginViewController.infoTextStr = message;
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (buttonIndex) {
        case 0:
            [self showLoginView:nil];
            break;
            
        default:
            [self showDetailViewIfNecessary];
            break;
    }
}

-(void) parserUpdateFinished {
    [delegateStack freeDelegate:@"parserManager"];
    [self showDetailViewIfNecessary];
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            //NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            //NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            //NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            //NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [controller dismissViewControllerAnimated:YES completion:NULL];
    [OfflineDataManager sharedOfflineDataManager].online = NO;
}


@end
