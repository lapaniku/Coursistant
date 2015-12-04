//
//  WebViewController.h
//  Coursistant
//
//  Created by Andrei Lapanik on 25.10.13.
//  Copyright (c) 2013 Altasapiens. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CWLSynthesizeSingleton.h"

@interface WebViewController : UIViewController <UIWebViewDelegate> {
    
    UIActivityIndicatorView *activityView;
}

//CWL_DECLARE_SINGLETON_FOR_CLASS(WebViewController)

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backBtn;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *stopBtn;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *refreshBtn;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *forwardBtn;

@property (strong, nonatomic) NSURL *resourceURL;

@property (strong, nonatomic) NSString *html;

+(NSString *) callJS;

@end
