//
//  CSTSideViewController.m
//  Coursistant Sceleton
//
//  Created by Администратор on 29.4.13.
//  Copyright (c) 2013 Andrew. All rights reserved.
//

#import "CSTSideViewController.h"
#import "IIViewDeckController.h"
#import "CSTDetailViewController.h"
#import "UIImage+iPhone5.h"
#import "SysInfo.h"
#import "CSTUnitedProfile.h"
#import "Flurry.h"

#import "CSTHowToViewController.h"

@interface CSTSideViewController ()

@end

@implementation CSTSideViewController

@synthesize detailViewController,loginController,appSettingsViewController;
@synthesize deckState;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.deckState = 1;
        
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    [self makeButtonShiny:self.deckSettings withBackgroundColor:[UIColor darkGrayColor]];
//    [self makeButtonShiny:self.deckCurrent withBackgroundColor:[UIColor darkGrayColor]];
//    [self makeButtonShiny:self.deckUpcoming withBackgroundColor:[UIColor darkGrayColor]];
//    [self makeButtonShiny:self.deckArchive withBackgroundColor:[UIColor darkGrayColor]];
    //self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"sidebar-pattern-retina.png"]];
    
    //UIColor* bgColor = [UIColor colorWithPatternImage:[UIImage tallImageNamed:@"sidebar-pattern-retina@2x.png"]];
    //[self.view setBackgroundColor:bgColor];
    self.versionLbl.text = [@"v. " stringByAppendingString:[[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey]];
#ifdef LITE_VERSION
    self.liteBg.hidden = NO;
    self.liteLb.hidden  = NO;
#endif
    

}



-(void) viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear: animated];
    
    NSString *lableTxt = [[NSString alloc] initWithFormat:@"Current (%i)",[self.detailViewController.coursesCurrent count] ];
    [self.deckCurrent setTitle:lableTxt forState:UIControlStateNormal];
    
    lableTxt = [NSString stringWithFormat:@"Upcoming (%i)",[self.detailViewController.coursesUpcoming count] ];
    [self.deckUpcoming setTitle:lableTxt forState:UIControlStateNormal];
    
    lableTxt = [NSString stringWithFormat:@"Archive (%i)",[self.detailViewController.coursesArchived count] ];
    [self.deckArchive setTitle:lableTxt forState:UIControlStateNormal];


}

- (void)makeButtonShiny:(UIButton*)button withBackgroundColor:(UIColor*)backgroundColor

{
    
    // Get the button layer and give it rounded corners with a semi-transparant button
    CALayer *layer = button.layer;
    //layer.cornerRadius = 8.0f;
    layer.masksToBounds = YES;
    layer.borderWidth = 3.0f;
    layer.borderColor = [UIColor colorWithWhite:0.6f alpha:0.4f].CGColor;
}

-(void)makeButtonSelected:(UIButton*)button
{
    
    [self.deckCurrent setBackgroundColor:[UIColor clearColor]];
    [self.deckCurrent setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

    
    [self.deckUpcoming setBackgroundColor:[UIColor clearColor]];
    [self.deckUpcoming setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [self.deckArchive setBackgroundColor:[UIColor clearColor]];
    [self.deckArchive setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [self.deckAccounts setBackgroundColor:[UIColor clearColor]];
    [self.deckAccounts setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [self.deckSettings setBackgroundColor:[UIColor clearColor]];
    [self.deckSettings setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [self.deckFeedback setBackgroundColor:[UIColor clearColor]];
    [self.deckFeedback setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [self.deckAbout setBackgroundColor:[UIColor clearColor]];
    [self.deckAbout setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [self.deckHowTo setBackgroundColor:[UIColor clearColor]];
    [self.deckHowTo setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [button setBackgroundColor:[UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1.0]];
    [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];

    
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setDeckSettings:nil];
    [self setDeckCurrent:nil];
    [self setDeckUpcoming:nil];
    [self setDeckArchive:nil];
    [self setDeckFeedback:nil];
    [self setDeckAbout:nil];
    [self setDeckAccounts:nil];
    [super viewDidUnload];
}

- (IBAction)currentPressed:(id)sender {
    [self makeButtonSelected:sender];
    self.deckState = 1;
    
        if ([self.viewDeckController.centerController isKindOfClass:[UINavigationController class]]) {
            
            NSArray *viewControllers = [[NSArray alloc] initWithObjects: self.detailViewController, nil];
            [(UINavigationController*)self.viewDeckController.centerController setViewControllers:viewControllers animated:NO];
            UITableViewController* cc = (UITableViewController*)((UINavigationController*)self.viewDeckController.centerController).topViewController;
            cc.navigationItem.title =  @"CURRENT COURSES";
            [self.detailViewController.notificationTextView setText:@"No current courses found.\nYou can enroll at coursera.org or udacity.com"];
            [self.detailViewController.collectionViewCurrent reloadData];
        }
    
}

- (IBAction)upcomingPressed:(id)sender {
    
    [self makeButtonSelected:sender];
    self.deckState = 2;
    
        if ([self.viewDeckController.centerController isKindOfClass:[UINavigationController class]]) {
            
            NSArray *viewControllers = [[NSArray alloc] initWithObjects: self.detailViewController, nil];
            [(UINavigationController*)self.viewDeckController.centerController setViewControllers:viewControllers animated:NO];
            UITableViewController* cc = (UITableViewController*)((UINavigationController*)self.viewDeckController.centerController).topViewController;
            cc.navigationItem.title =  @"UPCOMING COURSES";
            [self.detailViewController.notificationTextView setText:@"No upcoming courses found.\nYou can enroll at coursera.org or udacity.com "];
            [self.detailViewController.collectionViewCurrent reloadData];
        }
    
}

- (IBAction)archivePressed:(id)sender {
    [self makeButtonSelected:sender];
    self.deckState = 3;
    
   
        if ([self.viewDeckController.centerController isKindOfClass:[UINavigationController class]]) {
            
            NSArray *viewControllers = [[NSArray alloc] initWithObjects: self.detailViewController, nil];
            [(UINavigationController*)self.viewDeckController.centerController setViewControllers:viewControllers animated:NO];
            UITableViewController* cc = (UITableViewController*)((UINavigationController*)self.viewDeckController.centerController).topViewController;
            cc.navigationItem.title =  @"ARCHIVED COURSES";
            [self.detailViewController.notificationTextView setText:@"No archived courses found"];
            [self.detailViewController.collectionViewCurrent reloadData];
        }
}

- (IBAction)feedbackPressed:(id)sender {
    
    [self makeButtonSelected:sender];
    
    
    
    
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    if (mailClass != nil) {
        if([mailClass canSendMail]) {
                
            NSString *emailTitle = @"Coursistant feedback";
            // Email Content
            NSString *messageBody = [[NSString alloc] initWithFormat:@"Please, let us know what do you think about Coursistant. All additional information about your environment and courses is prepared for convenience and used for debug purposes only. You can easily remove it. Thanks for your input!<br /><br /><br /><br /><br /><br />Environment Info:<br />Version: %@ %@<br />%@<br /%@<br />%@<br /><br />Courses:<br />%@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"], [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey] ,[SysInfo deviceInfo], [SysInfo reportMemory], [SysInfo spaceInfo], [[CSTUnitedProfile sharedCSTUnitedProfile] coursesDescription]];
           
            // To address
            NSArray *toRecipents = [NSArray arrayWithObject:@"support@coursistant.com"];
            
            MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
            mc.mailComposeDelegate = self;

            
            [mc setSubject:emailTitle];
            [mc setMessageBody:messageBody isHTML:YES];
            [mc setToRecipients:toRecipents];
            
            // Present mail view controller on screen
            
            //[self presentModalViewController:mc animated:YES];
            [self presentViewController:mc animated:YES completion:NULL];
        } 
//            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Feedback to Coursistant" message:@"Mail options were disabled on your device or mail client is not set up. Still, we would like to hear from you - please email to hello@coursitant.com" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
//            [alertView show];

    
    }
    
    
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
}

- (IBAction)aboutPressed:(id)sender {
    [self makeButtonSelected:sender];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://facebook.com/coursistant/"]];
    NSDictionary *eventParam = [NSDictionary dictionaryWithObjectsAndKeys: @"aboutPressed", @"item", nil];
    [Flurry logEvent:@"MenuNav" withParameters:eventParam];
}

- (IBAction)howToPressed:(id)sender {
    [self makeButtonSelected:sender];
    UINavigationController *modalViewNavController = [[UINavigationController alloc] init];
    
 	CSTHowToViewController *howToVC = [[CSTHowToViewController alloc] initWithNibName:@"CSTHowToViewController" bundle:nil];
                                       
	modalViewNavController = [[UINavigationController alloc] initWithRootViewController:howToVC];
	
	modalViewNavController.modalPresentationStyle = UIModalPresentationPageSheet;
	
	[self presentModalViewController:modalViewNavController animated:YES];
    NSDictionary *eventParam = [NSDictionary dictionaryWithObjectsAndKeys: @"howToPressed", @"item", nil];
    [Flurry logEvent:@"MenuNav" withParameters:eventParam];
    
}

- (IBAction)accountsPressed:(id)sender {
    [self makeButtonSelected:sender];
    self.deckState = 4;
    
    [self.viewDeckController closeLeftViewAnimated:YES completion:^(IIViewDeckController *controller, BOOL success) {
        
        if ([controller.centerController isKindOfClass:[UINavigationController class]]) {
            
            NSArray *viewControllers = [[NSArray alloc] initWithObjects: self.loginController, nil];
            [(UINavigationController*)controller.centerController setViewControllers:viewControllers animated:NO];
            UITableViewController* cc = (UITableViewController*)((UINavigationController*)controller.centerController).topViewController;
            cc.navigationItem.title =  @"ACCOUNTS";
        }
        
        
    }];
    NSDictionary *eventParam = [NSDictionary dictionaryWithObjectsAndKeys: @"accountsPressed", @"item", nil];
    [Flurry logEvent:@"MenuNav" withParameters:eventParam];
}

- (IBAction)settingsPressed:(id)sender {
    [self makeButtonSelected:sender];
    self.deckState = 5;
    
    [self.viewDeckController closeLeftViewAnimated:YES completion:^(IIViewDeckController *controller, BOOL success) {
        
        if ([controller.centerController isKindOfClass:[UINavigationController class]]) {
            
            NSArray *viewControllers = [[NSArray alloc] initWithObjects: self.appSettingsViewController, nil];
            [(UINavigationController*)controller.centerController setViewControllers:viewControllers animated:NO];
            UITableViewController* cc = (UITableViewController*)((UINavigationController*)controller.centerController).topViewController;
            cc.navigationItem.title =  @"SETTINGS";
        }
        
        
    }];
    NSDictionary *eventParam = [NSDictionary dictionaryWithObjectsAndKeys: @"settingsPressed", @"item", nil];
    [Flurry logEvent:@"MenuNav" withParameters:eventParam];
}


@end
