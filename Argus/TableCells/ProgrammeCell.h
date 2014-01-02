//
//  ProgrammeCell.h
//  Argus
//
//  Created by Chris Elsworth on 04/05/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ArgusUpcomingProgramme.h"

@interface ProgrammeCell : UITableViewCell

@property (nonatomic, retain) ArgusProgramme *Programme;

@property (nonatomic, weak) IBOutlet UILabel *title;
@property (nonatomic, weak) IBOutlet UILabel *time;
@property (nonatomic, weak) IBOutlet UILabel *desc;

// upcoming recording icon
@property (nonatomic, weak) IBOutlet UIImageView *icon;

-(void)populateCellWithProgramme:(ArgusProgramme *)_Programme;

@end
