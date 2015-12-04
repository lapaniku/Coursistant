//
//  CSTSettingsViewController.m
//  Coursistant
//
//  Created by Администратор on 21.11.13.
//  Copyright (c) 2013 Altasapiens. All rights reserved.
//

#import "CSTSettingsViewController.h"
#import <MessageUI/MessageUI.h>
#import "IASKSettingsReader.h"
#import "CustomViewCell.h"

#import "IIViewDeckController.h"
#import "CSTSideViewController.h"

#import "AlertViewBlocks.h"

@interface CSTSettingsViewController ()
- (void)settingDidChange:(NSNotification*)notification;

@end

@implementation CSTSettingsViewController

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//
//
//    }
//    return self;
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.delegate = self;
    BOOL enabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"AutoConnect"];
    self.hiddenKeys = enabled ? nil : [NSSet setWithObjects:@"AutoConnectLogin", @"AutoConnectPassword", nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingDidChange:) name:kIASKAppSettingChanged object:nil];
    self.showDoneButton = NO;
    [self setShowCreditsFooter:NO];

    
    [self.navigationController setNavigationBarHidden:NO];
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark IASKAppSettingsViewControllerDelegate protocol
- (void)settingsViewControllerDidEnd:(IASKAppSettingsViewController*)sender {
    [self dismissModalViewControllerAnimated:YES];
	
	// your code here to reconfigure the app for changed settings
}

- (CGFloat)settingsViewController:(id<IASKViewController>)settingsViewController
                        tableView:(UITableView *)tableView
        heightForHeaderForSection:(NSInteger)section {
    //    NSString* key = [settingsViewController.settingsReader keyForSection:section];
    //	if ([key isEqualToString:@"IASKLogo"]) {
    //		return [UIImage imageNamed:@"Icon.png"].size.height + 25;
    //	} else if ([key isEqualToString:@"IASKCustomHeaderStyle"]) {
    //		return 55.f;
    //    }
	return 0;
}

- (UIView *)settingsViewController:(id<IASKViewController>)settingsViewController
                         tableView:(UITableView *)tableView
           viewForHeaderForSection:(NSInteger)section {
    //    NSString* key = [settingsViewController.settingsReader keyForSection:section];
    //	if ([key isEqualToString:@"IASKLogo"]) {
    //		UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Icon.png"]];
    //		imageView.contentMode = UIViewContentModeCenter;
    //		return imageView;
    //	} else if ([key isEqualToString:@"IASKCustomHeaderStyle"]) {
    //        UILabel* label = [[UILabel alloc] initWithFrame:CGRectZero];
    //        label.backgroundColor = [UIColor clearColor];
    //        label.textAlignment = UITextAlignmentCenter;
    //        label.textColor = [UIColor redColor];
    //        label.shadowColor = [UIColor whiteColor];
    //        label.shadowOffset = CGSizeMake(0, 1);
    //        label.numberOfLines = 0;
    //        label.font = [UIFont boldSystemFontOfSize:16.f];
    //
    //        //figure out the title from settingsbundle
    //        label.text = [settingsViewController.settingsReader titleForSection:section];
    //
    //        return label;
    //    }
	return nil;
}

- (CGFloat)tableView:(UITableView*)tableView heightForSpecifier:(IASKSpecifier*)specifier {
    //	if ([specifier.key isEqualToString:@"customCell"]) {
    //		return 44*3;
    //	}
	return 0;
}


- (UITableViewCell*)tableView:(UITableView*)tableView cellForSpecifier:(IASKSpecifier*)specifier {
	CustomViewCell *cell = (CustomViewCell*)[tableView dequeueReusableCellWithIdentifier:specifier.key];
	
	if (!cell) {
		cell = (CustomViewCell*)[[[NSBundle mainBundle] loadNibNamed:@"CustomViewCell"
															   owner:self
															 options:nil] objectAtIndex:0];
	}
	cell.textView.text= [[NSUserDefaults standardUserDefaults] objectForKey:specifier.key] != nil ?
    [[NSUserDefaults standardUserDefaults] objectForKey:specifier.key] : [specifier defaultStringValue];
	cell.textView.delegate = self;
	[cell setNeedsLayout];
	return cell;
}

#pragma mark kIASKAppSettingChanged notification
- (void)settingDidChange:(NSNotification*)notification {
    //	if ([notification.object isEqual:@"AutoConnect"]) {
    //		IASKAppSettingsViewController *activeController = self.tabBarController.selectedIndex ? self.tabAppSettingsViewController : self.appSettingsViewController;
    //		BOOL enabled = (BOOL)[[notification.userInfo objectForKey:@"AutoConnect"] intValue];
    //		[activeController setHiddenKeys:enabled ? nil : [NSSet setWithObjects:@"AutoConnectLogin", @"AutoConnectPassword", nil] animated:YES];
    //	}
    
#ifdef LITE_VERSION
    if ([notification.object rangeOfString:@"full"].location != NSNotFound) {
        UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"Premium functionality"
                                                       message:@"To enable this setting you can get the full version of Coursistant app."
                                                      delegate:nil
                                             cancelButtonTitle:@"No, thanks"
                                             otherButtonTitles:@"Full Version", nil];
        
        BOOL value = [[NSUserDefaults standardUserDefaults] boolForKey:notification.object];
        [[NSUserDefaults standardUserDefaults] setBool:!value forKey:notification.object];
        
//        if ([notification.object isEqual:@"delete_confirmation_full"]){
//            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:notification.object];
//        }
        
        [alert showAlerViewFromButtonAction:nil
                                   animated:YES
                                    handler:^(UIAlertView *alertView, NSInteger buttonIndex){
                                        if(buttonIndex == 1) {
                                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/coursistant/id681213120?mt=8&uo=4"]];
                                        }
                                    }];
    }
#endif
}

#pragma mark UITextViewDelegate (for CustomViewCell)
- (void)textViewDidChange:(UITextView *)textView {
    [[NSUserDefaults standardUserDefaults] setObject:textView.text forKey:@"customCell"];
    [[NSNotificationCenter defaultCenter] postNotificationName:kIASKAppSettingChanged object:@"customCell"];
}

#pragma mark -
- (void)settingsViewController:(IASKAppSettingsViewController*)sender buttonTappedForSpecifier:(IASKSpecifier*)specifier {
	if ([specifier.key isEqualToString:@"ButtonDemoAction1"]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Demo Action 1 called" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
	} else if ([specifier.key isEqualToString:@"ButtonDemoAction2"]) {
		NSString *newTitle = [[[NSUserDefaults standardUserDefaults] objectForKey:specifier.key] isEqualToString:@"Logout"] ? @"Login" : @"Logout";
		[[NSUserDefaults standardUserDefaults] setObject:newTitle forKey:specifier.key];
	}
}

@end
