//
//  LoadingSpinner.m
//  Argus
//
//  Created by Chris Elsworth on 02/04/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

// This is the controlling class called from my code.
// It inits a LoadingSpinnerViewController by loading a nib which has one in it.

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
		// this is an autolayout nib, and its so simple one nib will do for iPad and iPhone
		self.vc = [[[NSBundle mainBundle] loadNibNamed:@"LoadingSpinner" owner:self options:nil] firstObject];
	}
	return self;
}

-(void)presentOnView:(UIView *)targetView
{
	//NSLog(@"%s", __PRETTY_FUNCTION__);
	
	// the fullscreen main view in the nib
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
