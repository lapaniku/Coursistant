//
//  CSTSideViewController.h
//  Coursistant Sceleton
//
//  Created by Администратор on 29.4.13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
@class IIViewDeckController;
@class CSTDetailViewController;
@class CSTLoginViewController;
@class CSTSettingsViewController;
#import <MessageUI/MessageUI.h>


@interface CSTSideViewController : UIViewController <MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *deckSettings;
@property (weak, nonatomic) IBOutlet UIButton *deckCurrent;
@property (weak, nonatomic) IBOutlet UIButton *deckUpcoming;
@property (weak, nonatomic) IBOutlet UIButton *deckArchive;
@property (weak, nonatomic) IBOutlet UIButton *deckFeedback;
@property (weak, nonatomic) IBOutlet UIButton *deckAbout;
@property (weak, nonatomic) IBOutlet UIButton *deckHowTo;
@property (weak, nonatomic) IBOutlet UIButton *deckAccounts;

- (IBAction)settingsPressed:(id)sender;
- (IBAction)currentPressed:(id)sender;
- (IBAction)upcomingPressed:(id)sender;
- (IBAction)archivePressed:(id)sender;
- (IBAction)feedbackPressed:(id)sender;
- (IBAction)aboutPressed:(id)sender;
- (IBAction)howToPressed:(id)sender;
- (IBAction)accountsPressed:(id)sender;

@property (strong, nonatomic) CSTDetailViewController *detailViewController;
@property (strong, nonatomic) CSTLoginViewController *loginController;
@property (strong, nonatomic) CSTSettingsViewController *appSettingsViewController;

@property int deckState;

@property (weak, nonatomic) IBOutlet UILabel *versionLbl;
@property (weak, nonatomic) IBOutlet UILabel *liteLb;
@property (weak, nonatomic) IBOutlet UIImageView *liteBg;




@end
