//
//  RotatingTabBarController.m
//  Argus
//
//  Created by Chris Elsworth on 02/03/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import "RotatingTabBarController.h"
#import "AppDelegate.h"

@implementation RotatingTabBarController

-(id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self)
	{
		self.delegate = self;
	}
	
	return self;
}

-(void)viewDidLoad
{
	[super viewDidLoad];
	
	[self restoreSavedOrder];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

-(void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
	if (!changed)
		return;
	
	NSLog(@"%s", __PRETTY_FUNCTION__);

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	NSMutableArray *orderedVcTitles = [NSMutableArray new];
	
	for (UINavigationController *nc in viewControllers)
		[orderedVcTitles addObject:[nc title]];
	
	// save this new order
	[defaults setObject:orderedVcTitles forKey:@"TabBarViewControllerOrder"];
}

-(void)restoreSavedOrder
{
	NSLog(@"%s", __PRETTY_FUNCTION__);
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	NSMutableArray *orderedVcTitles = [defaults objectForKey:@"TabBarViewControllerOrder"];
	
	// forget their original order if the count of viewControllers has changed
	// so they'll see the new view controller (which wasn't in orderedVcTitles)
	if ([orderedVcTitles count] != [self.viewControllers count])
	{
		[defaults removeObjectForKey:@"TabBarViewControllerOrder"];
		return;
	}
	
	NSMutableArray *orderedVc = [NSMutableArray new];
	
	for (NSString *title in orderedVcTitles)
	{
		for (UINavigationController *nc in self.viewControllers)
		{
			if ([[nc title] isEqualToString:title])
				[orderedVc addObject:nc];
		}
	}
	
	[self setViewControllers:orderedVc animated:NO];
}


@end
