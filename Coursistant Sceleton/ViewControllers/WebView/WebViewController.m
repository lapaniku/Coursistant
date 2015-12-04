//
//  WebViewController.m
//  Coursistant
//
//  Created by Andrei Lapanik on 25.10.13.
//  Copyright (c) 2013 Altasapiens. All rights reserved.
//

#import "WebViewController.h"
#import "CSTCommonBarButton.h"

@interface WebViewController ()
- (void)updateButtons;

@end

@implementation WebViewController

//CWL_SYNTHESIZE_SINGLETON_FOR_CLASS(WebViewController);

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.webView.delegate = self;
    NSURLCache *URLCache = [[NSURLCache alloc] initWithMemoryCapacity:4 * 1024 * 1024 diskCapacity:256 * 1024 * 1024 diskPath:nil];
    [NSURLCache setSharedURLCache:URLCache];
    
    //////left bar button
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 39, 29)];
    [backButton setImage:[UIImage imageNamed:@"back-btn.png"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *sideButtonBar = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    BOOL aboveIOS61 = kCFCoreFoundationVersionNumber > kCFCoreFoundationVersionNumber_iOS_6_1;
    if (aboveIOS61) {
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                           initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                           target:nil action:nil];
        negativeSpacer.width = -10;
        
        [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects:negativeSpacer, sideButtonBar, self.backBtn, self.stopBtn, self.refreshBtn, self.forwardBtn, nil] animated:NO];
    } else
        //self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backB
        [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects: sideButtonBar, self.backBtn, self.stopBtn, self.refreshBtn, self.forwardBtn, nil] animated:NO];
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if(self.html) {
        [self.webView loadHTMLString:self.html baseURL:nil];
        
    } else {
        
        NSURLRequest *request = [NSURLRequest requestWithURL:self.resourceURL];
        [activityView startAnimating];
        activityView.center = self.webView.center;
        [self.webView addSubview:activityView];
        [self.webView loadRequest:request];
    }
}

- (void) viewDidDisappear:(BOOL)animated {
    
    [self.webView loadHTMLString:@"" baseURL:nil];
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL)webView:(UIWebView *)webView2
shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType {
    
    NSString *requestString = [[request URL] absoluteString];
    
    //NSLog(@"request : %@",requestString);
    
    if ([requestString hasPrefix:@"js-frame:"]) {
        
        NSArray *components = [requestString componentsSeparatedByString:@":"];
        
        NSString *function = (NSString*)[components objectAtIndex:1];
        
        if ([function isEqualToString:@"goBack"]) {
            
            [self goBack];
        } else if ([function isEqualToString:@"tryAgain"]) {
            
            [self.webView loadHTMLString:self.html baseURL:nil];
        } else {
            NSLog(@"Unimplemented method '%@'",function);
        }
        
        return NO;
    }
    
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [activityView stopAnimating];
    [activityView removeFromSuperview];
    NSString *html = [self.webView stringByEvaluatingJavaScriptFromString: @"document.body.innerHTML"];
    if([html rangeOfString:@"\"correct\":"].location != NSNotFound) {
        if([html rangeOfString:@"\"correct\":false"].location != NSNotFound) {
            NSString *responseCode = [[NSString alloc] initWithFormat:@"<script>%@</script><h1>Miss the target. No problem, you can try again.</h1><input type=\"button\" value=\"Try Again\" onclick=\"call('tryAgain');\" />", [WebViewController callJS]];
            [self.webView loadHTMLString:responseCode baseURL:nil];
        } else if([html rangeOfString:@"\"correct\":true"].location != NSNotFound) {
            NSString *responseCode = [[NSString alloc] initWithFormat:@"<script>%@</script><h1>Congratulations! Your answer is correct. Good mark to move on. </h1><input type=\"button\" value=\"Continue\" onclick=\"call('goBack');\" />", [WebViewController callJS]];
            [self.webView loadHTMLString:responseCode baseURL:nil];
        } else {
            [self.webView loadHTMLString:@"Unknown Response" baseURL:nil];
        }
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self updateButtons];
}


- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
// http://stackoverflow.com/questions/19304311/not-able-to-load-the-filedoc-pdf-etc-from-url-in-uiwebview-for-ios-7
//    NSData *dataFromUrl = [NSData dataWithContentsOfURL:self.resourceURL];
//    [self.webView loadData:dataFromUrl MIMEType:@"text/plain" textEncodingName:nil baseURL:nil];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self updateButtons];
}


-(void)goBack{
    [[self navigationController] popViewControllerAnimated:YES];
}

+(NSString *) callJS {
    return @"function call(functionName) {var iframe = document.createElement(\"IFRAME\");iframe.setAttribute(\"src\", \"js-frame:\"+functionName);iframe.setAttribute(\"height\", \"1px\");iframe.setAttribute(\"width\", \"1px\");document.documentElement.appendChild(iframe);iframe.parentNode.removeChild(iframe);iframe = null;}";
}

//http://iosdeveloperzone.com/2013/11/17/tutorial-building-a-web-browser-with-uiwebview-revisited-part-1/
- (void)updateButtons
{
    self.forwardBtn.enabled = self.webView.canGoForward;
    self.backBtn.enabled = self.webView.canGoBack;
    self.stopBtn.enabled = self.webView.loading;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self updateButtons];
}


@end
