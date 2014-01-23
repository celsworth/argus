//
//  LoadingSpinner.m
//  Argus
//
//  Created by Chris Elsworth on 02/04/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "LoadingSpinner.h"
#import "AppDelegate.h"

// private properties
@interface LoadingSpinner ()
@property (nonatomic, retain) LoadingSpinnerViewController *vc;
@end

@implementation LoadingSpinner

-(id)init
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	
	if (self = [super init])
	{
		UIStoryboard *tmp = [UIStoryboard storyboardWithName:(iPad() ? @"LoadingSpinner_iPad" : @"LoadingSpinner_iPhone") bundle:nil];
		self.vc = [tmp instantiateInitialViewController];
	}
	return self;
}

-(void)presentOnView:(UIView *)targetView
{
	//NSLog(@"%s", __PRETTY_FUNCTION__);
	
	UIView *view = [self.vc view];
	
	view.backgroundColor = [UIColor colorWithWhite:0.4 alpha:0.5];
	
	// this makes us fit into the parent view
	view.frame = targetView.bounds;
	view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	
	[targetView addSubview:view];
}

-(void)setProgress:(CGFloat)pctDone
{
	UIProgressView *progressView = [self.vc progressView];
	
	progressView.hidden = NO;
	progressView.progress = pctDone/100.0;
}

-(void)fadeOut
{
	//NSLog(@"%s", __PRETTY_FUNCTION__);
	[UIView animateWithDuration:0.1
					 animations:^{self.vc.view.backgroundColor = [UIColor clearColor];}
					 completion:^(BOOL finished) { [self.vc.view removeFromSuperview]; } ];
}

@end
