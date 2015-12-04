	    //
//  CSTLoginViewController.m
//  Coursistant Sceleton
//
//  Created by Администратор on 22.3.13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import "CSTLoginViewController.h"


#import "CSTDetailViewController.h"
#import "SSKeychain.h"

#import "GlobalProgressHUD.h"

#import "OfflineDataManager.h"

#import "IIViewDeckController.h"
#import "CSTSideViewController.h"

#import "CSTOnlineBarButton2.h"
#import "AlertViewBlocks.h"
#import "Flurry.h"



@interface CSTLoginViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@end

@implementation CSTLoginViewController{
    NSString *lastLoginCoursera;
    NSString *lastPswCoursera;
    NSString *lastLoginUdacity;
    NSString *lastPswUdacity;
    
}


@synthesize usernameField, passwordField, usernameFieldUda, passwordFieldUda,debuggingTextView;
@synthesize pass, login, providerName;
@synthesize infoTextStr;
@synthesize switchCourseraRound, switchUdacityRound;
// BANNER REMOVING
//@synthesize adBanner;
@synthesize applyButton;
@synthesize webViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //self.title = NSLocalizedString(@"Login", @"Login");
    }
    return self;
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    loginErrorFlag = NO;
     self.debuggingTextView.text = @"";

    [self setupReadonly:![OfflineDataManager sharedOfflineDataManager].online];
    //self.title = @"SETTINGS";
    
    [self loadSwitchStateFromUserDefaults];
    
    // if online state is changed, table view should be reloaded
    [CSTOnlineBarButton2 sharedOnlineButton2].onlineSwitchTrackingBlock = ^(BOOL online) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setupReadonly:!online];
        });
    };
    
    [self showOtherViewMessage];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.navigationController setNavigationBarHidden:NO];
    
    udacityService = [UdacityProviderService sharedUdacityProviderService];
    courseraService = [CourseraProviderService sharedCourseraProviderService];
    
    [self configureTextFields];
    usernameField.text= [[[SSKeychain accountsForService:@"CourseraSuccessLogin"] lastObject] objectForKey:@"acct"];
    passwordField.text=[SSKeychain passwordForService:@"CourseraSuccessLogin" account:usernameField.text];
    usernameField.tag = 1;
    passwordField.tag = 1;
    
    usernameFieldUda.text= [[[SSKeychain accountsForService:@"UdacitySuccessLogin"] lastObject] objectForKey:@"acct"];
    passwordFieldUda.text=[SSKeychain passwordForService:@"UdacitySuccessLogin" account:usernameFieldUda.text];
    usernameFieldUda.tag = 3;
    passwordFieldUda.tag = 3;
    
    UIColor* bgColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"backgroundVC.png"]];
    [self updateTextFieldStates];
    
    [self.view setBackgroundColor:bgColor];
    
    debuggingTextView.editable = NO;
    debuggingTextView.dataDetectorTypes = UIDataDetectorTypeAll;
    
    /////dismiss keyboard when tapped outside textfield
    
    tapper = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    tapper.cancelsTouchesInView = FALSE;
    /////
    
    /////load switch state
    
    /////setup switch archived
    [switchCourseraRound addTarget:self action:@selector(switchCourseraRoundChanged:) forControlEvents:UIControlEventValueChanged];
    switchCourseraRound.onTintColor = [UIColor colorWithRed:156.0/255.0 green:186.0/255.0 blue:63.0/255.0 alpha:1];
    switchCourseraRound.onText = @"CONNECTED";
    switchCourseraRound.offText = @"DISCONNECTED";

    [switchUdacityRound addTarget:self action:@selector(switchUdacityRoundChanged:) forControlEvents:UIControlEventValueChanged];
    switchUdacityRound.onTintColor = [UIColor colorWithRed:156.0/255.0 green:186.0/255.0 blue:63.0/255.0 alpha:1];
    switchUdacityRound.onText = @"CONNECTED";
    switchUdacityRound.offText = @"DISCONNECTED";
    
    BOOL state= [[NSUserDefaults standardUserDefaults] boolForKey:@"switchCoursera"];
    
    [switchCourseraRound setOn:state animated:NO];
    state= [[NSUserDefaults standardUserDefaults] boolForKey:@"switchUdacity"];
    [switchUdacityRound setOn:state animated:NO];
    /////
    
    /////viewdeck
    UIButton *sideButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [sideButton setImage:[UIImage imageNamed:@"side-btn.png"] forState:UIControlStateNormal];
    [sideButton addTarget:self.viewDeckController action:@selector(toggleLeftView) forControlEvents:UIControlEventTouchUpInside];
    BOOL aboveIOS61 = kCFCoreFoundationVersionNumber > kCFCoreFoundationVersionNumber_iOS_6_1;
    if (aboveIOS61) {
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                           initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                           target:nil action:nil];
        negativeSpacer.width = -5;
        UIBarButtonItem *sideButtonBar = [[UIBarButtonItem alloc] initWithCustomView:sideButton];
        [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:negativeSpacer, sideButtonBar, nil] animated:NO];
    } else
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:sideButton];
//    UIImage *sideDeckButtonImage = [UIImage tallImageNamed:@"side-btn.png.png"];
//    UIBarButtonItem* sidePannelButton = [[UIBarButtonItem alloc] init];
//    sidePannelButton.customView = [[UIImageView alloc] initWithImage:sideDeckButtonImage];
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:sideDeckButtonImage style:UIBarButtonItemStylePlain target:self.viewDeckController action:@selector(toggleLeftView)];
    
    /////
    
    UIBarButtonItem* onlineButton = [[UIBarButtonItem alloc] initWithCustomView:[CSTOnlineBarButton2 sharedOnlineButton2] ];
    
    
    if (aboveIOS61) {
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                           initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                           target:nil action:nil];
        negativeSpacer.width = -10;
        
        [self.navigationItem setRightBarButtonItems:@[negativeSpacer, onlineButton] animated:NO];
    } else
        self.navigationItem.rightBarButtonItems = @[onlineButton];


    
    applyButton.buttonBackgroundColor = [UIColor colorWithRed:157.0f/255.0f green:187.0f/255.0f blue:64.0f/255.0f alpha:1.0f];
    applyButton.buttonForegroundColor = [UIColor whiteColor];
    
   [self.signUpCourseraBtn setButtonBackgroundColor:[UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:0.9f]];
    [self.signUpCourseraBtn setButtonForegroundColor: [UIColor colorWithRed:59.0f/255.0f green:110.0f/255.0f blue:143.0f/255.0f alpha:1.0f]];
    [self.signUpUdacityBtn setButtonBackgroundColor:[UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:0.9f]];
    [self.signUpUdacityBtn setButtonForegroundColor: [UIColor colorWithRed:240.0f/255.0f green:118.0f/255.0f blue:33.0f/255.0f alpha:1.0f]];
    
    
}

-(void)viewWillDisappear:(BOOL)animated{

    
    
    [super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    if (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        return NO;
    }
    
    return YES;
}

-(void) showOtherViewMessage {
    if(infoTextStr != nil) {
        debuggingTextView.text = infoTextStr;
        infoTextStr = nil;
    }    
}

-(void) configureTextFields {
    
    UIImage *userImage = [UIImage imageNamed:@"user.png"];
    UIImageView *userImageView1 = [[UIImageView alloc] initWithImage:userImage highlightedImage:userImage];
    userImageView1.frame = CGRectMake(0, 0, 40, 40);
    userImageView1.contentMode = UIViewContentModeCenter;
    UIImageView *userImageView2 = [[UIImageView alloc] initWithImage:userImage highlightedImage:userImage];
    userImageView2.frame = CGRectMake(0, 0, 40, 40);
    userImageView2.contentMode = UIViewContentModeCenter;
    usernameField.leftView = userImageView1;
    usernameFieldUda.leftView = userImageView2;
    usernameField.leftViewMode = UITextFieldViewModeAlways;
    usernameFieldUda.leftViewMode = UITextFieldViewModeAlways;

    UIImage *passwordImage = [UIImage imageNamed:@"locked.png"];
    UIImageView *passwordImageView1 = [[UIImageView alloc] initWithImage:passwordImage highlightedImage:passwordImage];
    passwordImageView1.frame = CGRectMake(0, 0, 40, 40);
    passwordImageView1.contentMode = UIViewContentModeCenter;
    UIImageView *passwordImageView2 = [[UIImageView alloc] initWithImage:passwordImage highlightedImage:passwordImage];
    passwordImageView2.frame = CGRectMake(0, 0, 40, 40);
    passwordImageView2.contentMode = UIViewContentModeCenter;
    passwordField.leftView = passwordImageView1;
    passwordFieldUda.leftView = passwordImageView2;
    passwordField.leftViewMode = UITextFieldViewModeAlways;
    passwordFieldUda.leftViewMode = UITextFieldViewModeAlways;
}

-(void) updateTextFieldStates {

    if([OfflineDataManager sharedOfflineDataManager].online) {
        usernameField.backgroundColor = [UIColor colorWithRed:253.0f/255.0f green:255.0f/255.0f blue:196.0f/255.0f alpha:1.0f];
        //usernameField.borderStyle = UITextBorderStyleNone;
        usernameField.enabled = YES;
        usernameField.userInteractionEnabled = YES;
        
        usernameFieldUda.backgroundColor = [UIColor colorWithRed:253.0f/255.0f green:255.0f/255.0f blue:196.0f/255.0f alpha:1.0f];
        //usernameField.borderStyle = UITextBorderStyleNone;
        usernameFieldUda.enabled = YES;
        usernameFieldUda.userInteractionEnabled = YES;
        
        passwordField.backgroundColor = [UIColor colorWithRed:253.0f/255.0f green:255.0f/255.0f blue:196.0f/255.0f alpha:1.0f];
        //passwordField.borderStyle = UITextBorderStyleNone;
        passwordField.enabled = YES;
        passwordField.userInteractionEnabled = YES;
        
        passwordFieldUda.backgroundColor = [UIColor colorWithRed:253.0f/255.0f green:255.0f/255.0f blue:196.0f/255.0f alpha:1.0f];
        //passwordField.borderStyle = UITextBorderStyleNone;
        passwordFieldUda.enabled = YES;
        passwordFieldUda.userInteractionEnabled = YES;
        
    } else {
        usernameField.backgroundColor = [UIColor lightGrayColor];
        //usernameField.borderStyle = UITextBorderStyleLine;
        usernameField.enabled = NO;
        usernameField.userInteractionEnabled = NO;
        
        usernameFieldUda.backgroundColor = [UIColor lightGrayColor];
        //usernameField.borderStyle = UITextBorderStyleLine;
        usernameFieldUda.enabled = NO;
        usernameFieldUda.userInteractionEnabled = NO;
        
        passwordField.backgroundColor = [UIColor lightGrayColor];
        //passwordField.borderStyle = UITextBorderStyleLine;
        passwordField.enabled = NO;
        passwordField.userInteractionEnabled = NO;
        
        passwordFieldUda.backgroundColor = [UIColor lightGrayColor];
        //passwordField.borderStyle = UITextBorderStyleLine;
        passwordFieldUda.enabled = NO;
        passwordFieldUda.userInteractionEnabled = NO;
    }

}

-(void) setupReadonly:(BOOL)readonly {
    switchCourseraRound.enabled = !readonly;
    switchUdacityRound.enabled = !readonly;
    
    [self.signUpCourseraBtn setEnabled:!readonly];
    [self.signUpUdacityBtn setEnabled:!readonly];
    
    if (readonly) {
        [switchCourseraRound setOnTintColor:[UIColor lightGrayColor]];
        [switchUdacityRound setOnTintColor:[UIColor lightGrayColor]];
        
        [self.signUpCourseraBtn setButtonBackgroundColor:[UIColor lightGrayColor]];
        [self.signUpUdacityBtn setButtonBackgroundColor:[UIColor lightGrayColor]];
        
    } else {
        [switchCourseraRound setOnTintColor:[UIColor colorWithRed:156.0/255.0 green:186.0/255.0 blue:63.0/255.0 alpha:1]];
        [switchUdacityRound setOnTintColor:[UIColor colorWithRed:156.0/255.0 green:186.0/255.0 blue:63.0/255.0 alpha:1]];
        
        [self.signUpCourseraBtn setButtonBackgroundColor:[UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:0.9f]];
        [self.signUpUdacityBtn setButtonBackgroundColor:[UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:0.9f]];
    }    
    
    [self updateTextFieldStates];
    if(readonly) {
        debuggingTextView.text = @"You are currently in offline mode. Settings can be changed in online mode only.";
    } else {
        debuggingTextView.text = @"";
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setUsernameField:nil];
    [self setPasswordField:nil];
    [self setDebuggingTextView:nil];
    [self setUsernameFieldUda:nil];
    [self setPasswordFieldUda:nil];
    [self setApplyButton:nil];
    [self setSwitchCourseraRound:nil];
    [self setSwitchUdacityRound:nil];
    [super viewDidUnload];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"Cancel"]){
        [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
    }
    else if([title isEqualToString:@"Apply"]){
        [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
        [self doLoginConfirmed];
    }
}

- (void) doLoginConfirmed{
 
    /////save switch state
    [[NSUserDefaults standardUserDefaults] setBool:self.switchCourseraRound.on forKey:@"switchCoursera"];
    [[NSUserDefaults standardUserDefaults] setBool:self.switchUdacityRound.on forKey:@"switchUdacity"];
    /////
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    lastLoginCoursera = [usernameField text];
    lastPswCoursera = [passwordField text];
    lastLoginUdacity = [usernameFieldUda text];
    lastPswUdacity = [passwordFieldUda text];
    
    
    //delete all cookies everytime "Enter" is pressed. by pressing Enter we either want to login, change login, or relogin - mean update cookie
    [[courseraService loginManager:self] deleteCookies];
    [[udacityService loginManager:self] deleteCookies];

    
    [GlobalProgressHUD progressHudOn:self.view];
    
    loginErrorFlag = NO;
    
    BOOL flag = NO;
    
    if (switchCourseraRound.on  ) {
            [self enqueLoginKey:@"Coursera"];
            [[courseraService loginManager:self] doLogin:[usernameField text] password:[passwordField text]];
            flag = YES;
    }
    
    if ( switchUdacityRound.on ) {
             [self enqueLoginKey:@"Udacity"];
            [[udacityService loginManager:self] doLogin:[usernameFieldUda text] password:[passwordFieldUda text]];
            flag = YES;
    }
    
    if (!flag) {
        self.debuggingTextView.text = @"Please enter credentials for any of supported providers. You can sign up at coursera.org udacity.com";
        [self.detailViewController setCoursesCurrent:nil];
        [self.detailViewController setCoursesUpcoming:nil];
        [self.detailViewController setCoursesArchived:nil];
        [self.detailViewController setElementsVisibility:NO];

        [self.detailViewController.notificationTextView setText:@"No provider selected"];
        [GlobalProgressHUD progressHudOff:self.view];
    }
}

- (IBAction)doLogin:(id)sender {
    
    if ([self isFirstUsage]) {
        [self doLoginConfirmed];
        return;
        
    }
    if ([self checkIfCreditantialsChangedComparedToSaved]) {

        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Credentials change" message:@"For the changed credentials / switched provider the saved login information will be deleted (downloaded course materials will be preserved), and new structure will be attempted to download. Shall we apply changes?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Apply", nil];
            [alertView show];

        return;
    }
    
    else if ([self isSwichStatedChanged] || [self  checkIfCreditantialsChanged]) {
        
        [self doLoginConfirmed];
        return;
    }
    

    

    else {
        self.debuggingTextView.text = @"Credentials for switched providers were not changed, no need to relogin";
    }
}


#pragma mark - textfield delegate
- (void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField.tag == 1) {
        if (textField.text.length == 0) {
            [switchCourseraRound setOn:NO animated:YES];
        }
    }
    if (textField.tag == 3) {
        if (textField.text.length == 0) {
            [switchUdacityRound setOn:NO animated:YES];
        }
    }
}

#pragma mark - IProviderLoginDelegate
- (void) loggedInSuccessfully:(NSString *)aUserID provider:(NSString *)provider
{
    [self dequeLoginKey:provider];
    if([self isLoginCompleted]) {
        [GlobalProgressHUD progressHudOff:self.view];
    }
    
    NSString *successLoginKey = [provider stringByAppendingString:@"SuccessLogin"];

    
    if ([provider isEqualToString:@"Coursera"]) {
        //delete previous record
//        NSArray *accountsCoursera = [[NSArray alloc]  initWithArray:[SSKeychain accountsForService:@"CourseraSuccessLogin"]];
//        if (accountsCoursera) {
//            for (NSDictionary *user in accountsCoursera) {
//                [SSKeychain deletePasswordForService:@"CourseraSuccessLogin" account:[user valueForKey:kSSKeychainAccountKey]];
//                
//            }
//        }
        //save new psw
        [SSKeychain setPassword:passwordField.text forService:successLoginKey account:usernameField.text];
    }else if ([provider isEqualToString:@"Udacity"]){
        //delete previous record
//        NSArray *accountsUda = [[NSArray alloc]  initWithArray:[SSKeychain accountsForService:@"UdacitySuccessLogin"]];
//        if (accountsUda) {
//            for (NSDictionary *user in accountsUda) {
//                [SSKeychain deletePasswordForService:@"UdacitySuccessLogin" account:[user valueForKey:kSSKeychainAccountKey]];
//            }
//        }
        //save new psw
        [SSKeychain setPassword:passwordFieldUda.text forService:successLoginKey account:usernameFieldUda.text];
    }
    /////
    [[NSUserDefaults standardUserDefaults] setValue:@"1strun" forKey:@"FirstRun"];
    
    __block NSString *userIDstr;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //userIDstr = debuggingTextView.text;
        
        //userIDstr = [userIDstr stringByAppendingString:[aUserID description]];
        //debuggingTextView.text = userIDstr;
        if (!loginErrorFlag) {
            [self showProfile];
        } else {
            //userIDstr = debuggingTextView.text;
            
            userIDstr = [userIDstr stringByAppendingString:@"login for one of providers has failed, please check the correct credentials"];
            debuggingTextView.text = userIDstr;
            
        }
    });
}

- (void) loginErrorWithMessage:(NSString *)errorMessage provider:(NSString *)provider {
    
    [self dequeLoginKey:provider];
    if([self isLoginCompleted]) {
        [GlobalProgressHUD progressHudOff:self.view];
    }
    if(errorMessage != nil) {
        __block NSString *userIDstr;
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //userIDstr = debuggingTextView.text;
            userIDstr = @"Please verify your login/password details";
            //userIDstr = [userIDstr stringByAppendingString:errorMessage];
            loginErrorFlag = YES;
            debuggingTextView.text = userIDstr;
        });
    } else {
        loginErrorFlag = YES;
        
        NSDictionary *eventParam = [NSDictionary dictionaryWithObjectsAndKeys: @"loginErrorWithMessage", @"type", errorMessage, @"error", provider, @"provider", nil];
        [Flurry logEvent:@"LoginAccountsError" withParameters:eventParam];

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

- (void) loginProtocolError:(NSError *)error provider:(NSString *)provider
{
    NSDictionary *eventParam = [NSDictionary dictionaryWithObjectsAndKeys: @"loginProtocolError", @"type", [error localizedDescription], @"error", provider, @"provider", nil];
    [Flurry logEvent:@"LoginAccountsError" withParameters:eventParam];
    
    [self dequeLoginKey:provider];
    if([self isLoginCompleted]) {
        [GlobalProgressHUD progressHudOff:self.view];
    }
    __block NSString *userIDstr;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        //userIDstr = debuggingTextView.text;
        userIDstr = @"Please verify your login/password details";
        //userIDstr = [userIDstr stringByAppendingString:[error description]];
        loginErrorFlag = YES;
        debuggingTextView.text = userIDstr;
    });
}

- (void) loginRedirected:(NSURLRequest *)request provider:(NSString *)provider {
    NSDictionary *eventParam = [NSDictionary dictionaryWithObjectsAndKeys: @"loginRedirected", @"type", provider, @"provider", nil];
    [Flurry logEvent:@"LoginAccountsError" withParameters:eventParam];
    
    [self dequeLoginKey:provider];
    if([self isLoginCompleted]) {
        [GlobalProgressHUD progressHudOff:self.view];
    }
}

- (void) showProfile {

    if([self isLoginCompleted]) {
        CSTSideViewController *sideView = (CSTSideViewController*)self.viewDeckController.leftController;
        sideView.detailViewController.firstTimeAfterLogin = YES;
        [sideView currentPressed:sideView.deckCurrent];
    }
}

/////dismiss keyboard when tapped outside textfield
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{    
    [textField resignFirstResponder];
    
    return YES;
}
- (void)handleSingleTap:(UITapGestureRecognizer *) sender
{
    [self.view endEditing:YES];
}
/////

#pragma mark - Login Queue

-(void) enqueLoginKey:(NSString *)key {
    if(loginVerificationSet == nil) loginVerificationSet = [[NSMutableSet alloc] init];
    [loginVerificationSet addObject:key];
}

-(void) dequeLoginKey:(NSString *)key {
    if(loginVerificationSet != nil) {
        [loginVerificationSet removeObject:key];
    }
}

-(BOOL) isLoginCompleted {
    return (loginVerificationSet == nil) || (loginVerificationSet.count == 0);
}

-(BOOL) checkIfCreditantialsChangedComparedToSaved {
    
    if (switchCourseraRound.on){
        if (![[[SSKeychain accountsForService:@"CourseraSuccessLogin"] lastObject] objectForKey:@"acct"]) {
            return NO;
        }
        
        if (![usernameField.text isEqualToString:[[[SSKeychain accountsForService:@"CourseraSuccessLogin"] lastObject] objectForKey:@"acct"]]
            || ![passwordField.text isEqualToString:[SSKeychain passwordForService:@"CourseraSuccessLogin" account:usernameField.text]]) {
            return YES;
        }
        
    }
    
    if (switchUdacityRound.on){
        if (![[[SSKeychain accountsForService:@"UdacitySuccessLogin"] lastObject] objectForKey:@"acct"]) {
            return NO;
        }
        if (![usernameFieldUda.text isEqualToString:[[[SSKeychain accountsForService:@"UdacitySuccessLogin"] lastObject] objectForKey:@"acct"]]
            || ![passwordFieldUda.text isEqualToString:[SSKeychain passwordForService:@"UdacitySuccessLogin" account:usernameFieldUda.text]]) {
            return YES;
        }
        
    }
    return NO;
}

-(BOOL) checkIfCreditantialsChanged{
    if (switchCourseraRound.on){

        if (![usernameField.text isEqualToString:lastLoginCoursera]
            || ![passwordField.text isEqualToString:lastPswCoursera]) {
            return YES;
        }
        
    }
    
    if (switchUdacityRound.on){

        if (![usernameFieldUda.text isEqualToString:lastLoginUdacity]
            || ![passwordFieldUda.text isEqualToString:lastPswUdacity]) {
            return YES;
        }
        
    }
    return NO;


}


-(BOOL) isSwichStatedChanged {
    
    BOOL state= [[NSUserDefaults standardUserDefaults] boolForKey:@"switchCoursera"];
    if (switchCourseraRound.on != state){
        return YES;
    }
    state= [[NSUserDefaults standardUserDefaults] boolForKey:@"switchUdacity"];
    if (switchUdacityRound.on != state){
         return YES;
    }
    return NO;
}

-(BOOL) isFirstUsage{
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"FirstRun"]) {

        return NO;
    }
//    NSString *account = [[[SSKeychain accountsForService:@"CourseraSuccessLogin"] lastObject] objectForKey:@"acct"];
//    if (account.length != 0) {
//        return NO;
//    }
//
//    account = [[[SSKeychain accountsForService:@"UdacitySuccessLogin"] lastObject] objectForKey:@"acct"];
//    if (account.length != 0) {
//        return NO;
//    }

    return YES;
}


- (void)switchCourseraRoundChanged:(id)sender {
    if ((usernameField.text.length ==0  || passwordField.text.length ==0 ) && ( switchCourseraRound.on ) ) {
        [switchCourseraRound setOn:NO animated:YES];
        self.debuggingTextView.text = @"Username / password can not be empty for provider which is switched on";
    }
    [self updateTextFieldStates];
}

- (void)switchUdacityRoundChanged:(id)sender {
    if ((usernameFieldUda.text.length ==0  || passwordFieldUda.text.length ==0 ) && ( switchUdacityRound.on )) {
        [switchUdacityRound setOn:NO animated:YES];
        self.debuggingTextView.text = @"Username / password can not be empty for provider which is switched on";
    }
    [self updateTextFieldStates];

}

-(void)loadSwitchStateFromUserDefaults{
    /////load switch state
    BOOL state= [[NSUserDefaults standardUserDefaults] boolForKey:@"switchCoursera"];
    [self.switchCourseraRound setOn:state animated:NO];
    
    state= [[NSUserDefaults standardUserDefaults] boolForKey:@"switchUdacity"];
    [self.switchUdacityRound setOn:state animated:NO];
    /////
    
}

- (IBAction)goToProviderSite:(id)sender {
    UIButton *button = (UIButton *)sender;
    button.selected = NO;
    if (button.tag == 1) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://coursera.org/"]];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://udacity.com/"]];
    }
}

- (IBAction)removeKeyboard:(id)sender {
    [self.view endEditing:YES];
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

- (IBAction)signUpCoursera:(id)sender {
    if (webViewController == nil){
        webViewController = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil];
    }
    NSString *signUpLink = @"https://accounts.coursera.org/signup";
    [webViewController navigationItem].title = signUpLink;
    webViewController.resourceURL = [NSURL URLWithString:signUpLink];
    [self.navigationController pushViewController:webViewController animated:YES];
    NSDictionary *eventParam = [NSDictionary dictionaryWithObjectsAndKeys: @"Coursera", @"provider", nil];
    [Flurry logEvent:@"signUp" withParameters:eventParam];
    
}
- (IBAction)signUpUdacity:(id)sender {
    if (webViewController == nil){
        webViewController = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil];
    }
    NSString *signUpLink = @"https://www.udacity.com";
    [webViewController navigationItem].title = signUpLink;
    webViewController.resourceURL = [NSURL URLWithString:signUpLink];
    [self.navigationController pushViewController:webViewController animated:YES];
    NSDictionary *eventParam = [NSDictionary dictionaryWithObjectsAndKeys: @"Udacity", @"provider", nil];
    [Flurry logEvent:@"signUp" withParameters:eventParam];
}
@end

//NSArray* usernames = [[NSArray alloc] initWithObjects:@"alapanik@tut.by", @"alapanik@tut.by", @"alapanik@tut.by", nil];
//NSArray* passwords = [[NSArray alloc] initWithObjects:@"c0urs3r4", @"edx.org", @"ud4c1ty", nil];

//blue 61 174 211
//green 120 184 45
//coursera 59 110 143

