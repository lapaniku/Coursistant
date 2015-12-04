//
//  LanguageViewController.m
//  Coursistant
//
//  Created by Andrei Lapanik on 07.02.14.
//  Copyright (c) 2014 Altasapiens. All rights reserved.
//

#import "LanguageViewController.h"
#import "DownloadManager.h"
#import "DownloadItemHelper.h"
#import "CoursistantIAPHelper.h"
#import "ToastView.h"
#import "SettingsHelper.h"

@interface LanguageViewController ()

@end

@implementation LanguageViewController

@synthesize subtitles;
@synthesize languageTable;
@synthesize activity;
@synthesize downloadItem;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    tableItems = [[NSMutableArray alloc] init];
    languageIndex = [[NSMutableDictionary alloc] init];
    subtitleFiles = [[NSMutableArray alloc] init];
    delegateStack = [[DelegateStack alloc] init];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.buyButton.buttonBackgroundColor = [UIColor whiteColor];
    self.buyButton.buttonForegroundColor = [UIColor colorWithRed:61.0/255.0 green:174.0/255.0 blue:211.0/255.0 alpha:1.0];
    self.restoreButton.buttonBackgroundColor = [UIColor whiteColor];
    self.restoreButton.buttonForegroundColor = [UIColor colorWithRed:61.0/255.0 green:174.0/255.0 blue:211.0/255.0 alpha:1.0];
    
    if(![CoursistantIAPHelper sharedInstance].allLanguagesProduct) {
        [activity startAnimating];
        [[CoursistantIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
            [activity stopAnimating];
            if(success && products.count > 0) {
                SKProduct *product = [products objectAtIndex:0];
                [CoursistantIAPHelper sharedInstance].allLanguagesProduct = [products objectAtIndex:0];
                NSString *productTitle = [self.buyButton.currentTitle stringByReplacingOccurrencesOfString:@"$0.99" withString:[LanguageViewController localizedPrice:product]];
                [self.buyButton setTitle:productTitle forState:UIControlStateNormal];
                [self.buyButton setTitle:productTitle forState:UIControlStateSelected];
                
            } else {
//                [ToastView showToastInParentView: withText:(NSString *) withDuaration:(float)];
            }
        }];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    allLanguages = [[CoursistantIAPHelper sharedInstance] isAllLanguagesAvailable];
    if(allLanguages) {
        self.buyButton.hidden = YES;
        self.restoreButton.hidden = YES;
    }
    activity.hidden = YES;
    if(tableItems.count == 0) {
        BOOL activateNextSubtitle = YES;
        
        if(subtitles.count > 0) {
            [self.viewCaptionLabel setText:[[NSString alloc] initWithFormat:@"Available subtitles (%d)", subtitles.count]];

            NSArray *subtitlesForDisplay = [self englishFirstForSubtitleData:subtitles];
            for(int i = 0; i < subtitles.count; i++) {
                NSDictionary *subtitleData = [subtitlesForDisplay objectAtIndex:i];
                
                NSString *languageCode = [subtitleData objectForKey:@"language"];
                NSMutableDictionary *tableItem = [[NSMutableDictionary alloc] init];
                [tableItem setObject:[LanguageViewController languageCaption:languageCode] forKey:@"caption"];
                [tableItem setObject:[NSNumber numberWithBool:NO] forKey:@"active"];
                [tableItems addObject:tableItem];
                [languageIndex setObject:tableItem forKey:languageCode];

                DownloadItem *item = [DownloadItemHelper createSubtitleDownloadItem:subtitleData stencil:downloadItem];
                
                if(activateNextSubtitle) {
                    if([[DownloadManager sharedDownloadManager] isItemDownloaded:item]) {
                        [self activateSubtitle:languageCode];
                        NSDictionary *downloadedSubtitleInfo = [[NSDictionary alloc] initWithObjectsAndKeys:languageCode, @"code", [DownloadManager filePath:item], @"filepath", nil];
                        [subtitleFiles addObject:downloadedSubtitleInfo];

                    } else {
                        [delegateStack useDelegate:languageCode];
                        if(activity.hidden) {
                            [activity startAnimating];
                            activity.hidden = NO;
                        }
                        [[DownloadManager sharedDownloadManager] subtitleDownload:item completionBlock:^{
                            [delegateStack freeDelegate:languageCode];
                            if([delegateStack allDelegatesFree]) {
                                [activity stopAnimating];
                                activity.hidden = YES;
                            }
                            if([[DownloadManager sharedDownloadManager] isItemDownloaded:item]) {
                                [self activateSubtitle:languageCode];
                                NSDictionary *downloadedSubtitleInfo = [[NSDictionary alloc] initWithObjectsAndKeys:languageCode, @"code", [DownloadManager filePath:item], @"filepath", nil];
                                [subtitleFiles addObject:downloadedSubtitleInfo];
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [languageTable reloadData];
                                });
                            }
                            
                        }];
                    }
                }
                
                activateNextSubtitle = allLanguages;
            }
        } else {
            NSString *subtitlePath = [DownloadManager filePath:downloadItem];
            NSString *folder = [subtitlePath stringByDeletingLastPathComponent];
            NSString *file = [subtitlePath lastPathComponent];
            
            NSError *error;
            NSArray *directoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folder error:&error];
            if(!error) {
                NSString *match = [file stringByReplacingOccurrencesOfString:@".mp4" withString:@".subtitles.*.srt"];
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF like[cd] %@", match];
                NSArray *results = [self englishFirstForDownloadedSubtitles:[directoryContents filteredArrayUsingPredicate:predicate]];
                
                if(results.count > 0) {
                    for(NSString *subtitleFile in results) {
                        NSString *languageCode = [[subtitleFile stringByDeletingPathExtension] pathExtension];
                        NSDictionary *subtitleInfo = [[NSDictionary alloc] initWithObjectsAndKeys:languageCode, @"code", [folder stringByAppendingPathComponent:subtitleFile], @"filepath", nil];
                        [subtitleFiles addObject:subtitleInfo];
                        
                        NSMutableDictionary *subtitleItem = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[LanguageViewController languageCaption:languageCode], @"caption", [NSNumber numberWithBool:NO], @"active", nil];
                        [tableItems addObject:subtitleItem];
                        if(activateNextSubtitle) {
                            
                            [subtitleItem setValue:[NSNumber numberWithBool:YES] forKey:@"active"];
                        }
                        activateNextSubtitle = allLanguages;
                    }
                } else {
                    NSString *defaultSubtitlePath = [subtitlePath stringByReplacingOccurrencesOfString:@".mp4" withString:@".subtitles.srt"];
                    
                    if([[NSFileManager defaultManager] fileExistsAtPath:defaultSubtitlePath]) {
                        NSDictionary *subtitleInfo = [[NSDictionary alloc] initWithObjectsAndKeys:@"en", @"code", defaultSubtitlePath, @"filepath", nil];
                        [subtitleFiles addObject:subtitleInfo];
                        
                        NSMutableDictionary *subtitleItem = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[LanguageViewController languageCaption:@"en"], @"caption", [NSNumber numberWithBool:NO], @"active", nil];
                        [tableItems addObject:subtitleItem];
                    }
                }
            }
            [self.viewCaptionLabel setText:[[NSString alloc] initWithFormat:@"Available subtitles (%d)", tableItems.count]];

        }
    }
    [languageTable reloadData];
}

-(void) viewWillDisappear:(BOOL)animated {
    [tableItems removeAllObjects];
    [subtitleFiles removeAllObjects];
    [languageIndex removeAllObjects];
    if(![SettingsHelper isDefaultLanguageDefined]) {
        self.languageTrackingBlock(nil, nil);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return tableItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (nil == cell) {
        cell = [[UITableViewCell alloc]
                initWithStyle: UITableViewCellStyleValue1
                reuseIdentifier:cellIdentifier];
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:16];
    }
    NSString *currentItem = [[tableItems objectAtIndex:indexPath.row] objectForKey:@"caption"];
    cell.textLabel.text = currentItem;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *subtitleInfo = [subtitleFiles objectAtIndex:indexPath.row];
    self.languageTrackingBlock([subtitleInfo objectForKey:@"code"], [subtitleInfo objectForKey:@"filepath"]);
    [self dismiss];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BOOL active = [[[tableItems objectAtIndex:indexPath.row] objectForKey:@"active"] boolValue];
    if(active) {
        cell.textLabel.textColor = [UIColor blackColor];
    } else {
        cell.textLabel.textColor = [UIColor lightGrayColor];
    }
    
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL active = [[[tableItems objectAtIndex:indexPath.row] objectForKey:@"active"] boolValue];
    if (active) {
        return indexPath;
    }
    
    return nil;
}

#pragma mark - Utility

-(NSArray *) englishFirstForSubtitleData:(NSArray *)items {
    NSMutableArray *mutableItems = [items mutableCopy];
    for(int i = 0; i < items.count; i++) {
        NSDictionary *item = [items objectAtIndex:i];
        if([@"en" isEqualToString:[item objectForKey:@"language"]]) {
            [mutableItems removeObjectAtIndex:i];
            [mutableItems insertObject:item atIndex:0];
            return mutableItems;
        }
    }
    return items;
}

-(NSArray *) englishFirstForDownloadedSubtitles:(NSArray *)items {
    NSMutableArray *mutableItems = [items mutableCopy];
    for(int i = 0; i < items.count; i++) {
        NSString *item = [items objectAtIndex:i];
        if([item rangeOfString:@".en.srt"].location != NSNotFound) {
            [mutableItems removeObjectAtIndex:i];
            [mutableItems insertObject:item atIndex:0];
            return mutableItems;
        }
    }
    return items;
}

- (NSString *)translateLanguage:(NSDictionary *)subtitleData {
    NSString *code = [[subtitleData valueForKey:@"language"] substringToIndex:2];
    return [LanguageViewController languageCaption:code];
}

+ (NSString *)languageCaption:(NSString *)languageCode {
    NSDictionary *languageDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:@"English", @"en", @"Chinese", @"zh",  @"Francaise", @"fr", @"Russian", @"ru", @"Spanish", @"es", @"Portugese", @"pt", @"Turkish", @"tr", @"Ukrainian", @"uk", @"Deutch", @"de", @"Arabian", @"ar", @"Hebrew", @"he", @"Italian", @"it", @"Japanese", @"ja", nil];
    NSString *fullName = [languageDictionary valueForKey:languageCode];
    if(fullName == nil) fullName = languageCode;
    return fullName;
}

-(void) activateSubtitle:(NSString *)languageCode {
    NSMutableDictionary *tableItem = [languageIndex objectForKey:languageCode];
    if(tableItem) {
        [tableItem setObject:[NSNumber numberWithBool:YES] forKey:@"active"];
    }
}


- (IBAction)buySubtitles {
    [self dismiss];
    if([CoursistantIAPHelper sharedInstance].allLanguagesProduct ) {
        [[CoursistantIAPHelper sharedInstance] buyProduct:[CoursistantIAPHelper sharedInstance].allLanguagesProduct];
    } else {
        
    }
}

-(void) dismiss {
    [self.popover dismissPopoverAnimated:YES];
}

- (IBAction)restorePurchase {
    [self dismiss];
    [[CoursistantIAPHelper sharedInstance] restoreCompletedTransactions];
}

+ (NSString *)localizedPrice:(SKProduct*)product
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:product.priceLocale];
    NSString *formattedString = [numberFormatter stringFromNumber:product.price];
    return formattedString;
}

@end
