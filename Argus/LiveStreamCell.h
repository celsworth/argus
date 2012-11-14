//
//  LiveStreamCell.h
//  Argus
//
//  Created by Chris Elsworth on 05/05/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ArgusLiveStream.h"

@interface LiveStreamCell : UITableViewCell

@property (nonatomic, retain) ArgusLiveStream *LiveStream;

@property (nonatomic, weak) IBOutlet UILabel *channel;
@property (nonatomic, weak) IBOutlet UILabel *startTime;

@property (nonatomic, weak) IBOutlet UILabel *cardId;
@property (nonatomic, weak) IBOutlet UILabel *rtspURL;

@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *stoppingActivityIndicator;

-(void)populateCellWithLiveStream:(ArgusLiveStream *)_LiveStream;

@end
