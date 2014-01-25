//
//  LoadingSpinnerViewController.m
//  Argus
//
//  Created by Chris Elsworth on 19/09/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import "LoadingSpinnerViewController.h"

#import <QuartzCore/QuartzCore.h>

@interface LoadingSpinnerViewController ()

@end

@implementation LoadingSpinnerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	NSLog(@"%s", __PRETTY_FUNCTION__);

    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
	NSLog(@"%s", __PRETTY_FUNCTION__);

    [super viewDidLoad];
	// Do any additional setup after loading the view.
	
	// removed for iOS7
	//CGFloat cornerRadius = 10.0f;
	//[_pleaseWait.layer setCornerRadius:cornerRadius];
	
	[_pleaseWait.layer setBorderColor:[UIColor lightGrayColor].CGColor];
	[_pleaseWait.layer setBorderWidth:1.5f];
	
	[_pleaseWait.layer setShadowColor:[UIColor blackColor].CGColor];
	[_pleaseWait.layer setShadowOpacity:0.7];
	[_pleaseWait.layer setShadowRadius:2.0];
	[_pleaseWait.layer setShadowOffset:CGSizeMake(2, 2)];
	
	// removed for iOS7
	//[_pleaseWait.layer setShadowPath:[UIBezierPath bezierPathWithRoundedRect:_pleaseWait.bounds cornerRadius:cornerRadius].CGPath];

	_progressView.hidden = YES;
}

- (void)didReceiveMemoryWarning
{
	NSLog(@"%s", __PRETTY_FUNCTION__);

    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
