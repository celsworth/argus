//
//  ScheduleEditFileFormatTVC.h
//  Argus
//
//  Created by Chris Elsworth on 15/06/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ArgusBaseObject.h"

typedef enum {
	ArgusScheduleEditFileFormatTableSectionDefault = 0,
	ArgusScheduleEditFileFormatTableSectionList    = 1,
} ArgusScheduleEditFileFormatTableSection;

@interface ScheduleEditFileFormatTVC : UITableViewController

// ScheduleId that we are editing, so we can look up the details
@property (nonatomic, retain) ArgusGuid *ScheduleId;


-(IBAction)refreshPressed:(id)sender;

@end
