//
//  ConnectViewController.m
//  myGeoApp
//
//  Created by Сергей Табунщиков on 29.07.15.
//  Copyright (c) 2015 Сергей Табунщиков. All rights reserved.
//

#import "ConnectViewController.h"

#define kFoursquareAuthorizationDidChange @"foursquareAuthorizationDidChangeNotification"




@interface ConnectViewController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end




@implementation ConnectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    NSString *authURL = @"https://foursquare.com/oauth2/authorize";
    NSString *authURLString = [NSString stringWithFormat:@"%@?client_id=%@&response_type=token&redirect_uri=%@", authURL, @kCLIENTID, @kCLIENTREDIRECTURI];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:authURLString]];
    
    [self.webView loadRequest:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)cancelAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}




#pragma mark - Web view delegate

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    if([request.URL.scheme isEqualToString:@"mygeoapp"]){
        
        NSString *URLString = [[request URL] absoluteString];
        
        if ([URLString rangeOfString:@"access_token="].location != NSNotFound) {
            
            NSString *accessToken = [[URLString componentsSeparatedByString:@"="] lastObject];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:accessToken forKey:kFoursquareAccessToken];
            [defaults synchronize];
            
            [self dismissViewControllerAnimated:YES completion:^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kFoursquareAuthorizationChangedNotification object:nil];
            }];
        }
        return NO;
    }
    return YES;
}




@end
