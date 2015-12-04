//
//  ResourceDownloadViewController.m
//  Coursistant
//
//  Created by Andrei Lapanik on 22.10.13.
//  Copyright (c) 2013 Altasapiens. All rights reserved.
//

#import "ResourceDownloadViewController.h"
#import "DownloadManager.h"
#import "OfflineDataManager.h"
#import "AlertViewBlocks.h"
#import "CSTWeekViewController.h"
#import "Flurry.h"



@interface ResourceDownloadViewController ()

@end

@implementation ResourceDownloadViewController

@synthesize resources = _resources;
@synthesize resourceTable;
@synthesize lectureDownloadItem;
@synthesize downloadRemoveBtn3;
@synthesize docInteractionController;
@synthesize webViewController;
@synthesize weekViewController;


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
    if(accessoryViews == nil) {
        accessoryViews = [[NSMutableDictionary alloc] init];
    }

    self.downloadRemoveBtn3.buttonBackgroundColor = [UIColor whiteColor];
    self.downloadRemoveBtn3.buttonForegroundColor = [UIColor colorWithRed:61.0/255.0 green:174.0/255.0 blue:211.0/255.0 alpha:1.0];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.downloadActivity.hidden = YES;
    
    if([OfflineDataManager sharedOfflineDataManager].online) {
        self.downloadRemoveBtn3.userInteractionEnabled = YES;
        self.downloadRemoveBtn3.buttonBackgroundColor = [UIColor whiteColor];

    } else {
        self.downloadRemoveBtn3.userInteractionEnabled = NO;
        self.downloadRemoveBtn3.buttonBackgroundColor = [UIColor lightGrayColor];

    }
    [self updateDownloadState];
    self.resourseCountLbl.text = [NSString stringWithFormat:@"Additional course materials (%lu)",(unsigned long)[_resources count]];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateDownloadState {
    NSInteger downloadedResources = 0;
    for (int i = 0; i < _resources.count; i++) {
        DownloadItem *di = [self createDownloadItem:i];
        if([[DownloadManager sharedDownloadManager] isItemDownloaded:di]) {
            downloadedResources++;
        }
    }
    allDownloadedState = (downloadedResources == _resources.count);
    
    
    if(allDownloadedState) {
        
        [self.downloadRemoveBtn3 setFlatTitle:@"Remove"];

    } else {
        [self.downloadRemoveBtn3 setFlatTitle:@"Download"];

    
    }
    
    
}

- (IBAction)downloadRemoveBtnPressed:(id)sender {
    
//    NSDictionary *rs_downlbtn = [NSDictionary dictionaryWithObjectsAndKeys: @"resourse download/delete btn pressed", @"Rs_downlbtn_pressed", nil];
    
#ifdef LITE_VERSION
    UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"Premium functionality"
                                                   message:@"To enable resource download you can get the full version of Coursistant app."
                                                  delegate:nil
                                         cancelButtonTitle:@"No, thanks"
                                         otherButtonTitles:@"Full Version", nil];
    
    [alert showAlerViewFromButtonAction:nil
                               animated:YES
                                handler:^(UIAlertView *alertView, NSInteger buttonIndex){
                                    if(buttonIndex == 1) {
                                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/coursistant/id681213120?mt=8&uo=4"]];
                                    }
                                }];
    
#else
    DownloadManager *manager = [DownloadManager sharedDownloadManager];
    if(lectureDownloadItem != nil) {
        if(!allDownloadedState) {
            self.downloadRemoveBtn3.buttonBackgroundColor = [UIColor colorWithWhite:0.3 alpha:1.0];
            self.downloadRemoveBtn3.userInteractionEnabled = NO;
            self.downloadActivity.hidden = NO;
            [self.downloadActivity startAnimating];
            
            delegateStack = [[DelegateStack alloc] init];
            for (int i = 0; i < _resources.count; i++) {
                DownloadItem *di = [self createDownloadItem:i];
                if([self isResorceDownloadable:di]) {
                    if(![manager isItemDownloaded:di]) {
                        
                        [Flurry logEvent:@"Rs_downlbtn_pressed"];
                        
                        [delegateStack useDelegate:di.key];
                        [manager resourceDownload:di downloadProgressBlock:nil successCompletionBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
                            [delegateStack freeDelegate:di.key];
                            [self updateItemState:di];
                            if([delegateStack allDelegatesFree]) {
                                [self.downloadActivity stopAnimating];
                                self.downloadActivity.hidden = YES;
                                self.downloadRemoveBtn3.buttonBackgroundColor = [UIColor whiteColor];
                                self.downloadRemoveBtn3.userInteractionEnabled = YES;
                                [self updateDownloadState];
                            }
                        } failureCompletionBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
                            
                            NSLog(@"Error: %@", [error description]);
                            [delegateStack freeDelegate:di.key];
                            if([delegateStack allDelegatesFree]) {
                                [self.downloadActivity stopAnimating];
                                self.downloadRemoveBtn3.buttonBackgroundColor = [UIColor whiteColor];
                                self.downloadRemoveBtn3.userInteractionEnabled = YES;
                                [self updateDownloadState];
                            }
                        }];
                    }
                }
            }
        } else {
            for (int i = 0; i < _resources.count; i++) {
                DownloadItem *di = [self createDownloadItem:i];
                [manager deleteItem:di];
                [self updateItemState:di];
            }
            [self updateDownloadState];
        }
    }
#endif
}

-(BOOL) isResorceDownloadable:(DownloadItem*)di {
    NSString *extension = [di.extension pathExtension];
    return ![extension isEqualToString:@""];
}

-(void) setResources:(NSArray *)resources {
    _resources = resources;
    [resourceTable reloadData];
}

-(UIView *) resourceAccessoryView:(NSString *)key {
    UIView *view = [accessoryViews valueForKey:key];
    if(view == nil) {
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        [accessoryViews setValue:view forKey:key];
    }
    return view;
}

-(void) updateItemState:(DownloadItem *)di {
    BOOL downloadedState = [[DownloadManager sharedDownloadManager] isItemDownloaded:di];
    
    UIView *accessoryView = [self resourceAccessoryView:di.key];
    
    for (UIView *view in [accessoryView subviews]) {
//        if([view isKindOfClass:[UIImageView class]] && [view isKindOfClass:[UILabel class]]) {
        if (view.tag == 500) {
            [view removeFromSuperview];
        }
        
//        }
    }
    
    if(downloadedState) {
        
        UIImageView *downloadedImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hdd.png"]];
        downloadedImage.frame = CGRectMake(17, 17, 17, 17);
        downloadedImage.tag = 500;
        [accessoryView addSubview:downloadedImage];
    } else {
        if(![self isResorceDownloadable:di]) {
            UILabel *globeText = [[UILabel alloc]initWithFrame:CGRectMake(12, 12, 30, 30)];
            globeText.text = @"\U0001F30D";
            globeText.tag = 500;
            [globeText setFont:[UIFont systemFontOfSize:18]];
            [globeText setBackgroundColor:[UIColor clearColor]];
            [accessoryView addSubview:globeText];
        }
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_resources count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *currentItem = [_resources objectAtIndex:indexPath.row];
    static NSString *cellIdentifier = @"cell";
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (nil == cell) {
        cell = [[UITableViewCell alloc]
                        initWithStyle: UITableViewCellStyleValue1
                        reuseIdentifier:cellIdentifier];
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:16];
    }
    
    
    
    DownloadItem *di = [self createDownloadItem:indexPath.row];

    
    cell.accessoryView = [self resourceAccessoryView:di.key];
    
    [self updateItemState:di];
    
    cell.textLabel.text = [currentItem valueForKey:@"title"];
    
    if([self isCellSelectable:indexPath.row]) {
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    } else {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.popover dismissPopoverAnimated:NO];
    NSDictionary *resource = [_resources objectAtIndex:indexPath.row];
    DownloadItem *di = [self createDownloadItem:indexPath.row];
    NSString *resourceTitle = [resource objectForKey:@"title"];
    if (di != nil && [[DownloadManager sharedDownloadManager] isItemDownloaded:di]) {
        NSURL *fileURL = [NSURL fileURLWithPath:[DownloadManager filePath:di]];
        [self previewDocument:fileURL];
        

        NSDictionary *eventParam = [NSDictionary dictionaryWithObjectsAndKeys: resourceTitle, @"Rs_downloaded_opened_name", nil];
        [Flurry logEvent:@"Rs_downloaded_opened" withParameters:eventParam];
        
    } else {
        NSURL *url = [NSURL URLWithString:[resource objectForKey:@"link"]];
        
        
        [self openWebViewController:url title:resourceTitle];
        
        NSDictionary *eventParam = [NSDictionary dictionaryWithObjectsAndKeys: resourceTitle, @"Rs_online_opened_name", nil];
        [Flurry logEvent:@"Rs_online_pressed" withParameters:eventParam];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    cell.textLabel.textColor = [UIColor blackColor];
    if(cell.selectionStyle == UITableViewCellSelectionStyleNone) {
        cell.backgroundColor = [UIColor lightGrayColor];
    } else {
        cell.backgroundColor = [UIColor whiteColor];
    }
}

#pragma mark - Table view delegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self isCellSelectable:indexPath.row]) {
        return indexPath;
    }
    
    return nil;
}

- (BOOL) isCellSelectable:(NSInteger)row {
    
    DownloadItem *di = [self createDownloadItem:row];
    return ([OfflineDataManager sharedOfflineDataManager].online || [[DownloadManager sharedDownloadManager] isItemDownloaded:di]);
}


-(void) openWebViewController:(NSURL*)resourceURL title:(NSString*)title{
    
    [self.popover dismissPopoverAnimated:NO];
    

    if (self.weekViewController.webViewController == nil){
        self.weekViewController.webViewController = [[WebViewController alloc] initWithNibName:@"WebViewController" bundle:nil];
    }
    self.weekViewController.webViewController.title = title;
    self.weekViewController.webViewController.resourceURL = resourceURL;
    [self.weekViewController.navigationController pushViewController:self.weekViewController.webViewController animated:YES];
    
    
}

-(DownloadItem *) createDownloadItem:(NSInteger)itemIndex {
    NSDictionary *item = [_resources objectAtIndex:itemIndex];

    DownloadItem *di = [lectureDownloadItem mutableCopy];
    NSString *link = [item objectForKey:@"link"];
    di.key = link;
    di.url = [NSURL URLWithString:link];
    NSString *fullFileName = [[link  stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] lastPathComponent];
    NSString *fileExtension = [fullFileName pathExtension];
    NSString *fileName = [fullFileName stringByDeletingPathExtension];
    
    fullFileName = [fileName stringByAppendingPathExtension:fileExtension];
    if([fileName rangeOfString:@"subtitles"].location == NSNotFound) {
        fullFileName = [fullFileName stringByReplacingOccurrencesOfString:@"&" withString:@"_"];
        
        if((fileExtension != nil) && ![fileExtension isEqualToString:@""]) {
            if([fullFileName rangeOfString:fileExtension].location == NSNotFound) {
                fullFileName = [fileName stringByAppendingPathExtension:fileExtension];
            }
        }
        
    } else {
        fullFileName = @"subtitles.txt";
    }
    di.extension = fullFileName;
    return di;
}

- (void)setupDocumentControllerWithURL:(NSURL *)url
{
    if (docInteractionController == nil) {
        docInteractionController = [UIDocumentInteractionController interactionControllerWithURL:url];
        docInteractionController.delegate = self;
    } else {
        docInteractionController.URL = url;
    }
}

- (void)previewDocument:(NSURL *)resourceURL {
    
    [self setupDocumentControllerWithURL:resourceURL];
    
    if(![docInteractionController presentPreviewAnimated:YES]) {
        NSString *resourceTitle = [[[resourceURL absoluteString] lastPathComponent] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [self openWebViewController:resourceURL title:resourceTitle];
    }
}

#pragma mark -
#pragma mark UIDocumentInteractionControllerDelegate

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)interactionController
{
    return self.weekViewController.navigationController;
}

@end
