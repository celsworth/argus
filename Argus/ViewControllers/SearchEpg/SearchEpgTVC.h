//
//  SearchEpgTVC.h
//  Argus
//
//  Created by Chris Elsworth on 01/04/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoadingSpinner.h"

#import "ArgusSchedule.h"

@interface SearchEpgTVC : UITableViewController <UISearchBarDelegate>

@property (nonatomic, weak) IBOutlet UISearchBar *search;

@property (nonatomic, retain) ArgusSchedule *SearchSchedule;

@end