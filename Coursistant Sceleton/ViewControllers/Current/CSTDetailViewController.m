    //
//  CSTDetailViewController.m
//  Coursistant05
//
//  Created by Администратор on 5.3.13.
//  Copyright (c) 2013 Администратор. All rights reserved.
//

#import "CSTDetailViewController.h"

#import "Cell.h"
#import "CSTAddNewCourseCell.h"
#import "UIImageView+WebCache.h"
#import "SSKeychain.h"
#import "GlobalConst.h"

#import "OfflineDataManager.h"


#import "IIViewDeckController.h"
#import "CSTSideViewController.h"
#import "CollectionUtils.h"

#import "CSTOnlineBarButton2.h"
#import "CSTDownloadControlButton.h"


#import <CoreText/CoreText.h>
#import "NSFileManager+DirectoryLocations.h"

#import "AvailabilityInternal.h"
#import "AlertViewBlocks.h"
#import <Social/Social.h>
#import "CSTLoginViewController.h"
#import "Flurry.h"

@interface CSTDetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;


@end

@implementation CSTDetailViewController
{
    NSTimer *delayTimer;
    int delaySeconds;
}

//@synthesize coursesJson,coursesObjCurrent;
//@synthesize upcomingCoursesJson, coursesObjUpcoming;
@synthesize coursesPerProvider, coursesCurrent, coursesArchived, coursesUpcoming;

//
@synthesize courseraService, udacityService;
//

//list of weeks an video
@synthesize weekViewController, providerCourseName;
//

@synthesize scienceBranches;



#pragma mark - Managing the detail item


-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    

    if([OfflineDataManager sharedOfflineDataManager].online) {
        [self showOnlineProfile];
    } else {
        [self showOfflineProfile];
    }
}

-(void) setElementsVisibility: (BOOL) coursesExistFlag{
    
    [self.notificationTextView setHidden:coursesExistFlag];
    [self.collectionViewCurrent setHidden:!coursesExistFlag];
    
}


-(void) viewDidDisappear:(BOOL)animated{
    [self invalidateDelayTimer];
    [super viewDidDisappear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self.navigationController setNavigationBarHidden:NO];
    UINavigationItem *n = [self navigationItem];
    [n setTitle:@"CURRENT COURSES"];
    
    
    [self.collectionViewCurrent registerNib:[UINib nibWithNibName:@"CurrenCell" bundle:nil] forCellWithReuseIdentifier:@"cell02"];
    [self.collectionViewCurrent registerNib:[UINib nibWithNibName:@"CSTAddNewCourseCell" bundle:nil] forCellWithReuseIdentifier:@"AddNewCell"];
    
    
    self.weekViewController = [[CSTWeekViewController alloc] init];

    UIColor* bgColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"backgroundVC.png"]];
    [self.view setBackgroundColor:bgColor];
    flagProfileExtracted = NO;

  
    /////viewdeck
    
    UIButton *sideButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    [sideButton setImage:[UIImage imageNamed:@"side-btn.png"] forState:UIControlStateNormal];
    [sideButton addTarget:self.viewDeckController action:@selector(toggleLeftView) forControlEvents:UIControlEventTouchUpInside];
    
    //left bar button
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
    
   
    //right bar buttons
    [[CSTDownloadControlButton sharedCSTDownloadControlButton] update];
    
    UIBarButtonItem* onlineButton = [[UIBarButtonItem alloc] initWithCustomView:[CSTOnlineBarButton2 sharedOnlineButton2] ];

    UIBarButtonItem* downloadButton = [[UIBarButtonItem alloc] initWithCustomView:[CSTDownloadControlButton sharedCSTDownloadControlButton] ];
    
    if (aboveIOS61) {
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                           initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                           target:nil action:nil];
        negativeSpacer.width = -10;
        
        [self.navigationItem setRightBarButtonItems:@[negativeSpacer, onlineButton, downloadButton] animated:NO];
    } else
        self.navigationItem.rightBarButtonItems = @[onlineButton, downloadButton];
    
    
   
    /////
    PSTCollectionViewFlowLayout *flow = (PSTCollectionViewFlowLayout*)self.collectionViewCurrent.collectionViewLayout;
    flow.minimumLineSpacing = 30.0;
    
    ///// array with science branches from file
    
    NSString *path = [[[NSFileManager defaultManager] applicationSupportDirectory] stringByAppendingPathComponent:@"coursecategory.plist"];
    scienceBranches = [[NSDictionary alloc] initWithContentsOfFile:path];
    
    if ([scienceBranches count] == 0) {
        path = [[NSBundle mainBundle] pathForResource:@"coursecategoryBundle" ofType:@"plist"];
        scienceBranches = [[NSDictionary alloc] initWithContentsOfFile:path];
    }

    // Create the request.
//    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://coursistant.com/update/coursecategory.plist"]];
    
    // Create url connection and fire request
//    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    /////
    
    [self configureMessageButtons];
    unitedProfile = [CSTUnitedProfile sharedCSTUnitedProfile];
}

-(void) configureMessageButtons {
    
    self.refreshButton.buttonForegroundColor = [UIColor colorWithRed:61.0/255.0 green:174.0/255.0 blue:211.0/255.0 alpha:1.0];
    self.closeButton.buttonForegroundColor = [UIColor colorWithRed:61.0/255.0 green:174.0/255.0 blue:211.0/255.0 alpha:1.0];
    
    self.refreshButton.buttonBackgroundColor = [UIColor colorWithRed:212.0/255.0 green:237.0/255.0 blue:245.0/255.0 alpha:1.0];
    self.closeButton.buttonBackgroundColor = [UIColor colorWithRed:212.0/255.0 green:237.0/255.0 blue:245.0/255.0 alpha:1.0];
}

-(BOOL) updateGroupTitles
{

    if ([[self selectedDeckView] count] == 0) {
        //no courses for all logged in subscriptions - will present message
        return NO;
    }
    return YES;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    if (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        return NO;
    }
    
    return YES;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Detail", @"Detail");
    }
    return self;
}

							

#pragma mark - PSUICollectionView Datasource

- (NSInteger)collectionView:(PSUICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    // display message if there is no courses for logged in providers and hide collectionview
//    if (flagProfileExtracted) {
//        CSTSideViewController *sideView = (CSTSideViewController*)self.viewDeckController.leftController;
//        if (sideView.deckState == 1 && [coursesCurrent count]>0) {
//            [self setElementsVisibility:YES];
//            return [coursesCurrent count];
//        } else if (sideView.deckState == 2 && [coursesUpcoming count] >0){
//            [self setElementsVisibility:YES];
//            return [coursesUpcoming count] ;
//        } else if (sideView.deckState == 3 && [coursesArchived count] >0){
//            [self setElementsVisibility:YES];
//            return [coursesArchived count];
//        }
//        [self setElementsVisibility:NO];
//    }
    
    if (flagProfileExtracted) {
        CSTSideViewController *sideView = (CSTSideViewController*)self.viewDeckController.leftController;
        if (sideView.deckState == 1) {
            [self setElementsVisibility:YES];
            return [coursesCurrent count]+1;
        } else if (sideView.deckState == 2){
            [self setElementsVisibility:YES];
            return [coursesUpcoming count]+1;
        } else if (sideView.deckState == 3 && [coursesArchived count] >0){
            [self setElementsVisibility:YES];
            return [coursesArchived count];
        }
        [self setElementsVisibility:NO];
    }

    return 0;
        

}




- (PSUICollectionViewCell *)collectionView:(PSUICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == [self.selectedDeckView count] ) {
        CSTAddNewCourseCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"AddNewCell" forIndexPath:indexPath];
        cell.parentVC = self;
        return cell;
    }
    
    
    Cell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"cell02" forIndexPath:indexPath];
    
    NSDictionary *course = [[NSDictionary alloc]initWithDictionary:[self.selectedDeckView objectAtIndex:indexPath.row]];
    //course = [self.selectedDeckView objectAtIndex:indexPath.row];
    
    //background color based on category in scienceBranches
    
    
    NSString *currentScienceBranch = [scienceBranches valueForKey:[[course valueForKey:@"first_category"] description]];
    
    if ([currentScienceBranch isEqualToString:@"Natural"] ) {
        [cell.imageHeader setBackgroundColor: [UIColor colorWithRed:54.0/255.0 green:151.0/255.0 blue:175.0/255.0 alpha:1]];
        cell.imageFooter.image = [UIImage imageNamed:@"cell_footer_blue.png"];
        cell.courseCategory = @"Natural";
    }
    else if ([currentScienceBranch isEqualToString:@"Social"]){
        [cell.imageHeader setBackgroundColor: [UIColor colorWithRed:143.0/255.0 green:175.0/255.0 blue:54.0/255.0 alpha:1]];
        cell.imageFooter.image = [UIImage imageNamed:@"cell_footer_green.png"];
        cell.courseCategory = @"Social";
    }
    else if ([currentScienceBranch isEqualToString:@"Formal"]){
        [cell.imageHeader setBackgroundColor: [UIColor colorWithRed:175.0/255.0 green:65.0/255.0 blue:54.0/255.0 alpha:1]];
        cell.imageFooter.image = [UIImage imageNamed:@"cell_footer_red.png"];
        cell.courseCategory = @"Formal";
    }
    else if ([currentScienceBranch isEqualToString:@"Applied"]){
        [cell.imageHeader setBackgroundColor: [UIColor colorWithRed:45.0/255.0 green:45.0/255.0 blue:45.0/255.0 alpha:1]];
        cell.imageFooter.image = [UIImage imageNamed:@"cell_footer_black.png"];
        cell.courseCategory = @"Applied";
    }
    else {
        [cell.imageHeader setBackgroundColor: [UIColor colorWithRed:114.0/255.0 green:30.0/255.0 blue:80.0/255.0 alpha:1]];
        cell.imageFooter.image = [UIImage imageNamed:@"cell_footer_magenta.png"];
        cell.courseCategory = @"Other";
    }
    
    
    NSDate *startDate = [CollectionUtils extractDate:[course objectForKey:@"start_date"]];
    
    NSString *university = @"";
    if ([[[course valueForKey:@"provider"]description] isEqualToString:@"Coursera"])
    {
        university = [[[course valueForKey:@"university_short"]description] stringByAppendingString:@" / "];
    }

    NSString *startDateDisplayStr;
    
    
    if ([[startDate description]  isEqualToString:@"2199-12-31 00:00:00 +0000"]){
        //date to be determined by coursera
        startDateDisplayStr = @"TBD";
    }
    else if (startDate != nil) {
        startDateDisplayStr =[NSDateFormatter localizedStringFromDate:startDate dateStyle:NSDateFormatterShortStyle timeStyle: NSDateFormatterNoStyle];
    }
    else {
        //Udacity style
        startDateDisplayStr = @"Regular";
    }
    
    //NSString *startDateDisplayStr = (startDate != nil) ? [NSDateFormatter localizedStringFromDate:startDate dateStyle:NSDateFormatterShortStyle timeStyle: NSDateFormatterNoStyle] : @"Regular";

    
    NSString *courseDetails = [[NSString alloc] initWithFormat:@"Title: %@\nBy: %@%@\nStart Date: %@\nCategory: %@",
                                   [[course valueForKey:@"title"]description],
                                   university,
                                   [[course valueForKey:@"provider"]description],
                                   startDateDisplayStr,
                                    cell.courseCategory];
 
    
    
    [cell.label setText:courseDetails afterInheritingLabelAttributesAndConfiguringWithBlock:^ NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        NSRange titleRange = [[mutableAttributedString string] rangeOfString:@"Title:"];
        NSRange providerRange = [[mutableAttributedString string] rangeOfString:@"By:"];
        NSRange startDateRange = [[mutableAttributedString string] rangeOfString:@"Start Date:"];
        NSRange category = [[mutableAttributedString string] rangeOfString:@"Category:"];

        
        // Core Text APIs use C functions without a direct bridge to UIFont. See Apple's "Core Text Programming Guide" to learn how to configure string attributes.
        UIFont *boldSystemFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12];
        CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)boldSystemFont.fontName, boldSystemFont.pointSize, NULL);
        if (font) {
            [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:titleRange];
            [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:providerRange];
            [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:startDateRange];
            [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:category];
            CFRelease(font);
        }
        
        return mutableAttributedString;
    }];
    
    
    
    
    // load the image for this cell
    NSString *imageToLoad = [[course valueForKey:@"image_link"] description];
    [cell.image sd_setImageWithURL:[NSURL URLWithString:imageToLoad] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
    NSString *providerName = [[course valueForKey:@"provider"]description];
    if ([providerName isEqualToString:@"Udacity" ]) {
        cell.imageProvider.image = [UIImage imageNamed:@"flag-udacity.png"];
        cell.flagProviderLb.text = @"UDACITY";
    } else {
        cell.imageProvider.image = [UIImage imageNamed:@"flag-coursera.png"];
        cell.flagProviderLb.text = @"COURSERA";
    }
    
    return cell;
    
}


- (id<IProviderService>) providerService:(NSString *)aProvider {
    

    if ([aProvider isEqualToString: @"Udacity"]) {
        return [UdacityProviderService sharedUdacityProviderService];
    } else if ([aProvider isEqualToString: @"Coursera"]) {
        return [CourseraProviderService sharedCourseraProviderService];
    }else {
        return nil;
    }
}

#pragma mark - PSUICollectionViewDelegate
- (void)collectionView:(PSUICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.viewDeckController closeLeftViewAnimated:YES];
    
    
    if (indexPath.row == [self.selectedDeckView count] ) {
        return;
    }
    [self progressHudOn];
        
      selectedCourse = [self.selectedDeckView objectAtIndex:indexPath.row];
        [weekViewController setSelectedCourse:selectedCourse];
        providerCourseName = [[selectedCourse valueForKey:@"provider"] description];
       
        id<IProviderService> providerService = [self providerService:providerCourseName];
        id<IContentManager> contentManager = [providerService coursewareManager:self];
        if([contentManager isKindOfClass:[CourseraCoursewareManager class]]) {
            CourseraCoursewareManager *courseraCoursewareManager = (CourseraCoursewareManager *)contentManager;
            
            //NSDictionary *user = [[NSDictionary alloc] initWithDictionary:[[SSKeychain accountsForService:@"CourseraSuccessLogin"] lastObject]];
            courseraCoursewareManager.username =[[[SSKeychain accountsForService:@"CourseraSuccessLogin"] lastObject] objectForKey:@"acct"];
            courseraCoursewareManager.password = [SSKeychain passwordForService:@"CourseraSuccessLogin" account:courseraCoursewareManager.username ];
            
                                                  
                                                  
            NSString *openLink = [selectedCourse valueForKey:@"open_link"];
            NSURL *openURL = [[NSURL alloc] initWithString:openLink];
            
            NSString *courseLink = [selectedCourse valueForKey:@"home_link"];
            NSURL *courseURL = [[NSURL alloc] initWithString:courseLink];
            courseraCoursewareManager.courseURL = courseURL;
            
            [contentManager readContent:openURL title:[selectedCourse valueForKey:@"title"]];
        } else {
            NSString *courseLink = [selectedCourse valueForKey:@"home_link"];
            NSURL *courseURL = [[NSURL alloc] initWithString:courseLink];
            [contentManager readContent:courseURL title:[selectedCourse valueForKey:@"title"]];
        }
 

    
       [self.collectionViewCurrent
         deselectItemAtIndexPath:indexPath animated:YES];
    
    /////set bg color for weekVC
    NSString *currentScienceBranch = [scienceBranches valueForKey:[[selectedCourse valueForKey:@"first_category"] description]];
    
    if ([currentScienceBranch isEqualToString:@"Natural"] ) {
        weekViewController.currentScienceBranchNum = 1;
    }
    else if ([currentScienceBranch isEqualToString:@"Social"]){
        weekViewController.currentScienceBranchNum = 2;
    }
    else if ([currentScienceBranch isEqualToString:@"Formal"]){
        weekViewController.currentScienceBranchNum = 3;
    }
    else if ([currentScienceBranch isEqualToString:@"Applied"]){
        weekViewController.currentScienceBranchNum = 4;
    }
    else {
        weekViewController.currentScienceBranchNum = 5;
    }
    /////
    

//    }
    
}
- (void)collectionView:(PSUICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: Deselect item
}

- (NSInteger)numberOfSectionsInCollectionView: (PSUICollectionView *)collectionView {
    return 1;
}


#pragma mark – PSUICollectionViewDelegateFlowLayout

// 1
- (CGSize)collectionView:(PSUICollectionView *)collectionView layout:(PSUICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGSize cellSize = CGSizeMake(240, 300);

    return cellSize;
    
}



// 3
- (UIEdgeInsets)collectionView:
(PSUICollectionView *)collectionView layout:(PSUICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    BOOL atLeastIOS61 = kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_6_1;
    int itemsNumber = [self collectionView:self.collectionViewCurrent numberOfItemsInSection:1];
    
    if (atLeastIOS61) {
        
        if (itemsNumber == 1) {
            return UIEdgeInsetsMake(50, 400, 10, 10);
        } else if (itemsNumber == 2){
            return UIEdgeInsetsMake(50, 250, 10, 10);
        } else if (itemsNumber == 3){
            return UIEdgeInsetsMake(50, 100, 10, 10);
        } else if (itemsNumber > 10){
            return UIEdgeInsetsMake(70, 10, 10, 10);
        }
        
        
        return UIEdgeInsetsMake(50, 10, 10, 10);
    }
    
    if (itemsNumber == 1) {
        return UIEdgeInsetsMake(220, 400, 10, 10);
    } else if (itemsNumber == 2){
        return UIEdgeInsetsMake(220, 250, 10, 10);
    } else if (itemsNumber == 3){
        return UIEdgeInsetsMake(220, 100, 10, 10);
    } else if (itemsNumber > 10){
        return UIEdgeInsetsMake(50, 10, 10, 10);
    }
    
    return UIEdgeInsetsMake(220, 10, 10, 10);
    
    
    
    

    
}

- (CGFloat)collectionView:(PSUICollectionView *)collectionView layout:(PSUICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    
    int itemsNumber = [self collectionView:self.collectionViewCurrent numberOfItemsInSection:section];
    if (itemsNumber > 10) {

        return 10.0;
    }
    return 100.0;
}


-(void) parseCourses{
    coursesCurrent = [[NSMutableArray alloc] init];
    coursesUpcoming = [[NSMutableArray alloc] init];
    coursesArchived = [[NSMutableArray alloc] init];

    for (NSDictionary *course in coursesPerProvider){
        
        /////load switch state
  
        NSString *archivedKey;
        if ([[[course valueForKey:@"provider"]description] isEqualToString:@"Coursera"] && [course valueForKey:@"start_date"] != (id)[NSNull null]) {
            archivedKey = [[NSString alloc] initWithFormat:@"%@-%@-%@",[[course valueForKey:@"provider"]description],[[course valueForKey:@"title"]description],[[[course valueForKey:@"start_date"]description]substringToIndex:10]];
        } else {
            archivedKey = [[NSString alloc] initWithFormat:@"%@-%@",[[course valueForKey:@"provider"]description],[[course valueForKey:@"title"]description]];
            
        }
        
        BOOL archieved = [[NSUserDefaults standardUserDefaults] boolForKey:archivedKey];
        
        if ([[course objectForKey:@"provider"] isEqualToString:@"Udacity"]) {
            
            if (archieved) {
                [coursesArchived addObject:course];
            } else
                [coursesCurrent addObject:course];
            continue;
        }
        
        NSDate* startDate = nil;
        if([course valueForKey:@"start_date"] != (id)[NSNull null]) {
            startDate = [CollectionUtils extractDate:[course valueForKey:@"start_date"]];
        }
        
        NSDate* endDate = nil;
        if([course valueForKey:@"end_date"] != (id)[NSNull null]) {
            //end date + 14 days
            endDate = [[CollectionUtils extractDate:[course valueForKey:@"end_date"]] dateByAddingTimeInterval:60*60*24*14]; ;
            
        }
    
       NSString *state = [CollectionUtils courseState:startDate endDate:endDate actual:[course objectForKey:@"actual"] archived:archieved];
        
        if ([state isEqualToString: @"Current"]) {
            [coursesCurrent addObject:course];
        }
        else if ([state isEqualToString: @"Upcoming"]){
            if ( [[course objectForKey:@"provider"] isEqualToString:@"Coursera"] && [course valueForKey:@"start_date"] == (id)[NSNull null]){
                [course setValue:@"2199-12-31T21:00:00.000Z" forKey:@"start_date"];
            }
            [coursesUpcoming addObject:course];
            
        } else {
            [coursesArchived addObject:course];
            /////save Archived switch state
            //[[NSUserDefaults standardUserDefaults] setBool:YES forKey:archivedKey];
        }
    }

    ///// sort courses
    ///// upcoming
    
    NSSortDescriptor *sortByDate = [NSSortDescriptor sortDescriptorWithKey:@"start_date" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortByDate];
    NSArray *sortedArray = [coursesUpcoming sortedArrayUsingDescriptors:sortDescriptors];
    coursesUpcoming = [NSMutableArray arrayWithArray:sortedArray];

}





//IContentDelegate
- (void) contentExtracted:(NSArray *)courseware {
    
    
    self.weekViewController.weeks = courseware;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self invalidateDelayTimer];
        [self progressHudOff];
        [self.navigationController pushViewController:self.weekViewController animated:YES];
    });
}

- (void) contentError:(NSError *)error {
 
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSDictionary *eventParam = [NSDictionary dictionaryWithObjectsAndKeys: [error localizedDescription], @"error", nil];
        [Flurry logEvent:@"contentError" withParameters:eventParam];
        if([providerCourseName isEqualToString:@"Udacity"]) {
            self.weekViewController.weeks = nil;
            
        } else if([providerCourseName isEqualToString:@"Coursera"]) {
            self.weekViewController.weeks = nil;
            
        }
        
        [self invalidateDelayTimer];
        [self progressHudOff];
        [self.navigationController pushViewController:self.weekViewController animated:YES];
    });
}

- (void) notifyDelay{
    
    if(!delayTimer){
    delaySeconds = 30;
    delayTimer = [NSTimer scheduledTimerWithTimeInterval: 1.0
                                                      target:self
                                                selector:@selector(updateCountdown) 
                                                    userInfo:nil
                                                 repeats: YES];
    }
//    NSDictionary *eventParam = [NSDictionary dictionaryWithObjectsAndKeys: providerCourseName, @"provider", nil];
//    [Flurry logEvent:@"Delay_showed" withParameters:eventParam];
}

//

-(void) updateCountdown {
    
    
    self.delayLb.hidden = NO;
    delaySeconds--;
    self.delayLb.text = [NSString stringWithFormat:@"Course contains many items. Waiting for response sec:%02d", delaySeconds];
    if (delaySeconds == 0) {
        [[OperationService sharedOperationService] cancelAllOperations];
        [self invalidateDelayTimer];
    }
}
-(void) invalidateDelayTimer {
    
    
    [delayTimer invalidate];
    delayTimer = nil;
    self.delayLb.hidden = YES;
    
}


//progress
-(void) progressHudOn{
    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    HUD.labelText = @"loading";
}
-(void) progressHudOff{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)viewDidUnload {



    [self setNotificationTextView:nil];
    self.scienceBranches = nil;
    [self setRefreshButton:nil];
    [self setCloseButton:nil];
    [self setDelayLb:nil];
    [super viewDidUnload];
}

-(void) showOnlineProfile {
    
    [self progressHudOn];
    
    [unitedProfile renew:self];
    
    BOOL state= [[NSUserDefaults standardUserDefaults] boolForKey:@"switchCoursera"];
    NSString *userIDCoursera = [[OfflineDataManager sharedOfflineDataManager] userIDFor:@"Coursera"];
    if(userIDCoursera != nil && state) {
        unitedProfile.expectedRequestCount++;
        [[[CourseraProviderService sharedCourseraProviderService] profileManager:unitedProfile] readProfile:userIDCoursera];
        
    }
    
    state= [[NSUserDefaults standardUserDefaults] boolForKey:@"switchUdacity"];
    NSString *userIDUdacity = [[OfflineDataManager sharedOfflineDataManager] userIDFor:@"Udacity"];
    if(userIDUdacity != nil && state) {
        unitedProfile.expectedRequestCount++;
        [[[UdacityProviderService sharedUdacityProviderService] profileManager:unitedProfile] readProfile:userIDUdacity];
    }
    
    if (unitedProfile.expectedRequestCount == 0) {
        [self progressHudOff];
    }

}

//unitedProfile delegate
- (void) unitedProfileExtracted:(NSArray *)courseList newCourses:(NSArray *)newCourses errorMessage:(NSString *)errorMessage
{
    [self setCoursesPerProvider:courseList];
    [self parseCourses];

    dispatch_async(dispatch_get_main_queue(), ^{
        if(errorMessage != nil) {
            self.messageText.text = errorMessage;
            self.messageView.hidden = NO;
        }
   
        [self.collectionViewCurrent reloadData];
        [self progressHudOff];
    });
    flagProfileExtracted = YES;
    
    BOOL aboveIOS61 = kCFCoreFoundationVersionNumber > kCFCoreFoundationVersionNumber_iOS_6_1;
    BOOL sharingOn = [[NSUserDefaults standardUserDefaults] boolForKey:@"new_course_facebook_full"];
    if(([newCourses count] > 0) && ([newCourses count] <= 3) && aboveIOS61 && [OfflineDataManager sharedOfflineDataManager].online && !self.firstTimeAfterLogin && sharingOn) {
        NSString *reference;
        NSString *subject;
        if([newCourses count] == 1) {
            reference = @"it";
            subject = @"course";
        } else {
            reference = @"them";
            subject = @"courses";
        }
        NSString *message = [[NSString alloc] initWithFormat:@"Great, you've attended to new %@! Do you want to share your goal to complete %@ using Coursistant?", subject, reference];

        [Flurry logEvent:@"facebook_alert"];

        UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"Share with Facebook friends" message:message delegate:nil cancelButtonTitle:@"No, thanks" otherButtonTitles:@"Share", nil];
        [alert showAlerViewFromButtonAction:nil animated:YES handler:^(UIAlertView *alertView, NSInteger buttonIndex){
            if(buttonIndex == 1) {
                
                SLComposeViewController *fbController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
                
                NSString *title = @"Hey, I've just started the following ";
                title = [[title stringByAppendingString:subject] stringByAppendingString:@":\n"];
                
                NSString *courseraTitles = @"";
                NSString *udacityTitles = @"";
                for(NSDictionary *course in newCourses) {
                    NSString *provider = [course valueForKey:@"provider"];
                    NSString *courseTitle = [course valueForKey:@"title"];
                    if([@"Coursera" isEqualToString:provider]) {
                        if(![courseraTitles isEqualToString:@""]) {
                            courseraTitles = [courseraTitles stringByAppendingString:@", "];
                        }
                        courseraTitles = [courseraTitles stringByAppendingString:[[NSString alloc] initWithFormat:@"\"%@\"", courseTitle]];
                    } else if([@"Udacity" isEqualToString:provider]) {
                        if(![udacityTitles isEqualToString:@""]) {
                            udacityTitles = [udacityTitles stringByAppendingString:@", "];
                        }
                        udacityTitles = [udacityTitles stringByAppendingString:[[NSString alloc] initWithFormat:@"\"%@\"", courseTitle]];
                    }
                    [fbController addImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[course valueForKey:@"image_link"]]]]];

                }
                if(![courseraTitles isEqualToString:@""]) {
                    title = [[title stringByAppendingString:courseraTitles] stringByAppendingString:@" from Coursera\n"];
                }
                if(![udacityTitles isEqualToString:@""]) {
                    if(![courseraTitles isEqualToString:@""]) {
                        title = [title stringByAppendingString:@"and "];
                    }
                    
                    title = [[title stringByAppendingString:udacityTitles] stringByAppendingString:@" from Udacity\n"];
                }
                NSDictionary *eventParam = [NSDictionary dictionaryWithObjectsAndKeys: courseraTitles, @"courseraCourses", udacityTitles, @"udacityCourses", nil];

                
                title = [title stringByAppendingString:[[NSString alloc] initWithFormat:@"and I commit to complete %@ using Coursistant iPad App!", reference]];
                
                
                if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
                    SLComposeViewControllerCompletionHandler __block completionHandler=^(SLComposeViewControllerResult result){
                        
                        [fbController dismissViewControllerAnimated:YES completion:nil];
                        
                        switch(result){
                            case SLComposeViewControllerResultCancelled:
                            default:
                            {
//                                NSLog(@"Cancelled.....");
                                
                            }
                                break;
                            case SLComposeViewControllerResultDone:
                            {
                                
                                [Flurry logEvent:@"facebook_posting" withParameters:eventParam];

//                                NSLog(@"Posted....");
                            }
                                break;
                        }};
                    
                    [fbController setInitialText:title];
                    [fbController addURL:[NSURL URLWithString:@"http://coursistant.com"]];
                    [fbController setCompletionHandler:completionHandler];
                    [self presentViewController:fbController animated:YES completion:nil];
                } else {
//                    NSLog(@"no facebook setup");
                }
            }
        }];
    }
    self.firstTimeAfterLogin = NO;
}

-(void) showOfflineProfile {
    
    NSMutableArray *courseList = [[NSMutableArray alloc] init];
    BOOL state= [[NSUserDefaults standardUserDefaults] boolForKey:@"switchCoursera"];
    NSArray *courseraList = [[OfflineDataManager sharedOfflineDataManager] profileFor:@"Coursera"];
    if(courseraList != nil && state) {
        [courseList addObjectsFromArray:courseraList];
    }

    state= [[NSUserDefaults standardUserDefaults] boolForKey:@"switchUdacity"];
    NSArray *udacityList = [[OfflineDataManager sharedOfflineDataManager] profileFor:@"Udacity"];
    if(udacityList != nil && state) {
        [courseList addObjectsFromArray:udacityList];
    }
    
    [self setCoursesPerProvider:courseList];
    [self parseCourses];
    
    if ([coursesCurrent count] + [coursesUpcoming count] + [coursesArchived count] >0) {
        flagProfileExtracted = YES;
    }
    [self.collectionViewCurrent reloadData];

    [Flurry logEvent:@"shown_offline_profile"];

}


#pragma mark - check which tab was seleceted on deck
-(NSArray *) selectedDeckView{
    
    CSTSideViewController *sideView = (CSTSideViewController*)self.viewDeckController.leftController;
    
    if (sideView.deckState == 1) {
        return coursesCurrent; 
    } else if (sideView.deckState == 2){
        return coursesUpcoming;
    }
    
    return coursesArchived;
}

- (IBAction)refresh {
    self.messageView.hidden = YES;
    if([unitedProfile.httpResponseCode isEqualToString:@"Coursera401"]) {
        
        NSString *userName = [[[SSKeychain accountsForService:@"CourseraSuccessLogin"] lastObject] objectForKey:@"acct"];
        
        if (userName !=nil) {
            
            [self progressHudOn];
            [[[CourseraProviderService sharedCourseraProviderService] loginManager:self] doLogin:userName password:[SSKeychain passwordForService:@"CourseraSuccessLogin" account:userName]];
        }
    } else if([unitedProfile.httpResponseCode isEqualToString:@"Udacity401"]) {
        
        NSString *userName = [[[SSKeychain accountsForService:@"UdacitySuccessLogin"] lastObject] objectForKey:@"acct"];
        
        if (userName !=nil) {

            [self progressHudOn];
            [[[CourseraProviderService sharedCourseraProviderService] loginManager:self] doLogin:userName password:[SSKeychain passwordForService:@"UdacitySuccessLogin" account:userName]];
        }
    } else {
        
        [self showOnlineProfile];
    }
    NSDictionary *eventParam = [NSDictionary dictionaryWithObjectsAndKeys: unitedProfile.httpResponseCode, @"error_code", @"refreshed",@"user_act",  nil];
    [Flurry logEvent:@"Blue_error" withParameters:eventParam];
}

- (IBAction)closeMessage {
    self.messageView.hidden = YES;
    NSDictionary *eventParam = [NSDictionary dictionaryWithObjectsAndKeys: unitedProfile.httpResponseCode, @"error_code", @"closed",@"user_act",  nil];
    [Flurry logEvent:@"Blue_error" withParameters:eventParam];
}

#pragma mark Login Delegate for Relogin

- (void) loggedInSuccessfully:(NSString *)aUserID provider:(NSString *)provider {
    [self progressHudOff];
    [self showOnlineProfile];
    NSDictionary *eventParam = [NSDictionary dictionaryWithObjectsAndKeys: @"loggedInSuccessfully", @"result", nil];
    [Flurry logEvent:@"LoginDelegateforRelogin" withParameters:eventParam];
}

- (void) loginErrorWithMessage:(NSString *)errorMessage provider:(NSString *)provider {
    [self progressHudOff];
    self.messageText.text = errorMessage;
    self.messageView.hidden = NO;
    NSDictionary *eventParam = [NSDictionary dictionaryWithObjectsAndKeys: @"loginErrorWithMessage", @"result", errorMessage, @"errorMessage", nil];
    [Flurry logEvent:@"LoginDelegateforRelogin" withParameters:eventParam];
    
}

- (void) loginProtocolError:(NSError *)error provider:(NSString *)provider {
    [self progressHudOff];
    self.messageText.text = [error localizedDescription];
    self.messageView.hidden = NO;
    NSDictionary *eventParam = [NSDictionary dictionaryWithObjectsAndKeys: @"loginProtocolError", @"result", [error localizedDescription], @"errorMessage", nil];
    [Flurry logEvent:@"LoginDelegateforRelogin" withParameters:eventParam];
}

- (void) loginRedirected:(NSURLRequest *)request provider:(NSString *)provider {
    NSDictionary *eventParam = [NSDictionary dictionaryWithObjectsAndKeys: @"loginRedirected", @"result", nil];
    [Flurry logEvent:@"LoginDelegateforRelogin" withParameters:eventParam];
}

#pragma mark UI methods

- (void) closeLeftBar{
    [self.viewDeckController closeLeftViewAnimated:YES];
}

@end
