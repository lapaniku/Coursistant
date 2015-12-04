//
//  CSTDetailViewController.h
//  Coursistant05
//
//  Created by Администратор on 5.3.13.
//  Copyright (c) 2013 Администратор. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSTCollectionView.h"
#import "MBProgressHUD.h"
#import "UdacityProviderService.h"
#import "CourseraProviderService.h"
#import "CSTWeekViewController.h"
#import "CSTUnitedProfile.h"

#import "JSFlatButton.h"

@interface CSTDetailViewController : UIViewController <PSUICollectionViewDataSource, PSUICollectionViewDelegateFlowLayout, IContentDelegate, UnitedProfileDelegate, ILoginDelegate>
{
    
    MBProgressHUD *HUD;
    NSDictionary *selectedCourse;
    CSTUnitedProfile *unitedProfile;
    BOOL flagProfileExtracted;
    NSMutableData *_responseData;
} 


//ilia
//collection view

@property(nonatomic, weak) IBOutlet PSUICollectionView *collectionViewCurrent;
//

//courses from file OLD
//@property NSArray *imageURL;
//@property (nonatomic, strong) NSMutableArray *coursesObjCurrent;


//@property NSArray *upcomingCoursesJson;
//@property (nonatomic, strong) NSMutableArray *coursesObjUpcoming;
//

//parsed courses NEW
@property NSArray *coursesPerProvider;

@property NSMutableArray *coursesCurrent;
@property NSMutableArray *coursesUpcoming;
@property NSMutableArray *coursesArchived;


-(void) parseCourses;
//

//cash image
//@property (strong, nonatomic) NSURL *imageURL;
//@property (strong, nonatomic) IBOutlet UIImageView *imageView;
//

//provider service

@property (weak, nonatomic) UdacityProviderService *udacityService;
@property (weak, nonatomic) CourseraProviderService *courseraService;

//
//list of weeks an video
@property (strong, nonatomic) CSTWeekViewController *weekViewController;
@property (weak, nonatomic) NSString *providerCourseName;
//

//lables

@property (weak, nonatomic) IBOutlet UITextView *notificationTextView;
//


-(void)progressHudOn;
-(void)progressHudOff;
-(NSArray *) selectedDeckView;

-(void) setElementsVisibility: (BOOL) coursesExistFlag;

@property BOOL firstTimeAfterLogin;

@property (strong, nonatomic) NSDictionary *scienceBranches;

@property (weak, nonatomic) IBOutlet UIView *messageView;

@property (weak, nonatomic) IBOutlet UITextView *messageText;

- (IBAction)refresh;

- (IBAction)closeMessage;

@property (weak, nonatomic) IBOutlet JSFlatButton *refreshButton;

@property (weak, nonatomic) IBOutlet JSFlatButton *closeButton;

- (void) notifyDelay;
@property (weak, nonatomic) IBOutlet UILabel *delayLb;

-(void) closeLeftBar;


@end
