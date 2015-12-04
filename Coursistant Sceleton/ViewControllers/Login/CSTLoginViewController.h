//
//  CSTLoginViewController.h
//  Coursistant Sceleton
//
//  Created by Администратор on 22.3.13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ILoginDelegate.h"
#import "IProfileDelegate.h"
#import "MBProgressHUD.h"
#import "CSTUnitedProfile.h"

#import "UdacityProviderService.h"
#import "CourseraProviderService.h"
#import "JSFlatButton.h"

@class CSTDetailViewController;

#import "DCRoundSwitch.h"
#import <MessageUI/MessageUI.h>
#import "WebViewController.h"



@interface CSTLoginViewController : UIViewController <ILoginDelegate, UITextFieldDelegate, UIAlertViewDelegate, MFMailComposeViewControllerDelegate>
{
    MBProgressHUD *HUD;

    UdacityProviderService *udacityService;
    CourseraProviderService *courseraService;
    NSArray *courses;
    BOOL loginErrorFlag;
    UIGestureRecognizer *tapper;
    NSMutableSet *loginVerificationSet;
}
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *usernameFieldUda;
@property (weak, nonatomic) IBOutlet UITextField *passwordFieldUda;

@property (strong, nonatomic) CSTDetailViewController *detailViewController;


@property (weak, nonatomic) IBOutlet UITextView *debuggingTextView;
- (IBAction)doLogin:(id)sender;

- (void)showProfile;
@property NSString *login;
@property NSString *pass;
@property NSString *providerName;



//seting infotext
@property (nonatomic, weak) NSString *infoTextStr;

/////dismiss keyboard when tapped outside textfield
- (void)handleSingleTap:(UITapGestureRecognizer *) sender;
/////

/////course switches
@property (weak, nonatomic) IBOutlet DCRoundSwitch *switchCourseraRound;
@property (weak, nonatomic) IBOutlet DCRoundSwitch *switchUdacityRound;

/////


@property (weak, nonatomic) IBOutlet JSFlatButton *applyButton;
- (IBAction)goToProviderSite:(id)sender;
- (IBAction)removeKeyboard:(id)sender;

@property (strong, nonatomic) WebViewController *webViewController;

@property (weak, nonatomic) IBOutlet JSFlatButton *signUpCourseraBtn;
- (IBAction)signUpCoursera:(id)sender;

@property (weak, nonatomic) IBOutlet JSFlatButton *signUpUdacityBtn;
- (IBAction)signUpUdacity:(id)sender;


@end
