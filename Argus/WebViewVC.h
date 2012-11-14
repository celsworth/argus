//
//  WebViewVC.h
//  Argus
//
//  Created by Chris Elsworth on 01/05/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewVC : UIViewController <UIWebViewDelegate>
@property (nonatomic, retain) UIWebView *view;

-(id)initWithFrame:(CGRect)frame;

-(void)loadRequest:(NSURLRequest *)req;

@end
