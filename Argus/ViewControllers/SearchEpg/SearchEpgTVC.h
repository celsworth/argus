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

#import "NoEntriesView.h"

@interface SearchEpgTVC : UITableViewController <UISearchBarDelegate>

@property (nonatomic, retain) NoEntriesView *noEntriesView;

@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;

@property (nonatomic, retain) ArgusSchedule *SearchSchedule;

@property (nonatomic, assign) BOOL isSearching;

@end
