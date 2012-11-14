//
//  MasterViewController.m
//  Argus
//
//  Created by Chris Elsworth on 01/03/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import "MasterViewController.h"

#import "DetailViewController.h"

#import "AppDelegate.h"

@implementation MasterViewController
@synthesize versionCell;

@synthesize hideShowMaster, masterHidden;

//@synthesize detailViewController = _detailViewController;

- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
		
		masterHidden = NO;
    }
    [super awakeFromNib];
	
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	// self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
		//	[self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionMiddle];
    }
	
	[argus getVersion];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(VersionDone)
												 name:kArgusVersionDone
											   object:argus];

	if (dark)
	{
		[[[self navigationController] navigationBar] setTintColor:[UIColor blackColor]];

		[self.tableView setBackgroundView:nil];
		[self.tableView setBackgroundColor:[UIColor lightGrayColor]];
	}
	
	//[self.view setBackgroundColor:[ArgusColours bgColour]];
	
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	
	[self updateHideMasterButton];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
       return YES;
}
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	masterHidden = NO;
	[self updateHideMasterButton];
	
	CGRect r = AppDelegate.sharedInstance.window.frame;
	//	NSLog(@"rotated; wf is now %f.%f, %fx%f", r.origin.x, r.origin.y, r.size.width, r.size.height);

	r.size.width = 768;
	r.size.height = 1024;
	AppDelegate.sharedInstance.window.frame = r;
	//	NSLog(@"rotated; wf fixed to %f.%f, %fx%f", r.origin.x, r.origin.y, r.size.width, r.size.height);

	NSLog(@"rotating to %d", toInterfaceOrientation);
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)VersionDone
{
	versionCell.detailTextLabel.text = [argus Version];
}

-(void)updateHideMasterButton
{
	if (masterHidden)
		hideShowMaster.image = [UIImage imageNamed:@"show_master.png"];
	else
		hideShowMaster.image = [UIImage imageNamed:@"hide_master.png"];
}

-(IBAction)hideShowPressed:(id)sender
{
	NSInteger moveBy;
	
	if (masterHidden)
		moveBy = +270;
	else 
		moveBy = -270;


	UISplitViewController *splitViewController = (UISplitViewController *)AppDelegate.sharedInstance.window.rootViewController;

	// this works, but not until the next rotation (can we force a redraw?)
	// and also the master disappears completely so we need a detail button to get it back somewhere
	//AppDelegate.sharedInstance.hideMaster = !AppDelegate.sharedInstance.hideMaster;
	//[[splitViewController view] setNeedsLayout];
	//return;
	
	//UIViewController *masterVC = [splitViewController.viewControllers objectAtIndex:0];
	//UIViewController *detailVC = [splitViewController.viewControllers objectAtIndex:1];
	//CGRect mvf = masterVC.view.frame;
	//CGRect dvf = detailVC.view.frame;

	CGRect wf = AppDelegate.sharedInstance.window.frame;
	//NSLog(@"wf was %f.%f, %fx%f", wf.origin.x, wf.origin.y, wf.size.width, wf.size.height);

	CGRect svf = splitViewController.view.frame;
	//NSLog(@"svf was %f.%f, %fx%f", svf.origin.x, svf.origin.y, svf.size.width, svf.size.height);

	
	switch ([[UIApplication sharedApplication] statusBarOrientation])
	{
		case UIDeviceOrientationLandscapeLeft:
			//NSLog(@"left");
			svf.origin.y += moveBy;
			wf.size.height -= moveBy;
			svf.size.height = wf.size.height;
			// this should be the "proper" way to do it, just messing with VCs, not the window
			// but the width can't be changed, don't know why? :(
			//mvf.origin.x += moveBy;
			//dvf.origin.x += moveBy;
			//dvf.size.width -= moveBy;
			break;
			
			case UIDeviceOrientationLandscapeRight:
			//NSLog(@"right");
			// odd one, we're basically "upside down" in portrait, so our origin is now top right?
			// so don't touch that..
			//svf.origin.y += moveBy;
			wf.size.height -= moveBy;
			svf.size.height = wf.size.height;
			break;

		case UIDeviceOrientationPortrait:
			//NSLog(@"portrait");
			svf.origin.x += moveBy;
			wf.size.width -= moveBy;
			svf.size.width = wf.size.width;
			break;

		case UIDeviceOrientationPortraitUpsideDown:
			//NSLog(@"upsidedown");
			//svf.origin.x -= moveBy;
			wf.size.width -= moveBy;
			svf.size.width = wf.size.width;
			break;

	}

	//masterVC.view.frame = mvf;
	//detailVC.view.frame = dvf;
	
	//[UIView beginAnimations:nil context:nil];
	//[UIView setAnimationDuration:0.5f];
	
	AppDelegate.sharedInstance.window.frame = wf;
	splitViewController.view.frame = svf;
	
	//NSLog(@"wf is %f.%f, %fx%f", wf.origin.x, wf.origin.y, wf.size.width, wf.size.height);
	//NSLog(@"svf is %f.%f, %fx%f", svf.origin.x, svf.origin.y, svf.size.width, svf.size.height);

	masterHidden = !masterHidden;
	
	[self updateHideMasterButton];
	//[UIView commitAnimations];

	// tell anyone who cares (maybe they want to relayout their own view)
	[[NSNotificationCenter defaultCenter] postNotificationName:kArgusSidePanelDisplayStateChanged object:self];
	
	return;
}

@end
