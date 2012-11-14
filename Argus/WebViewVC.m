//
//  WebViewVC.m
//  Argus
//
//  Created by Chris Elsworth on 01/05/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import "WebViewVC.h"

@implementation WebViewVC
@synthesize view;

-(id)initWithFrame:(CGRect)frame
{
	self = [super init];
	if (self)
	{
		view = [[UIWebView alloc] initWithFrame:frame];
		[view setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];

		[view setScalesPageToFit:YES];

	}
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

-(void)loadRequest:(NSURLRequest *)req
{
	[view loadRequest:req];
}


@end
