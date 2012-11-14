//
//  EpgGridLabel.h
//  Argus
//
//  Created by Chris Elsworth on 04/04/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "EpgGridDefines.h"

#import "ArgusProgramme.h"

@class EpgGridLabel;
@protocol EpgGridLabelDelegate <NSObject>
-(void)epgGridLabel:(EpgGridLabel *)epgGridLabel receivedTapOn:(UITapGestureRecognizer *)recognizer;
-(void)epgGridLabel:(EpgGridLabel *)epgGridLabel receivedLongPressOn:(UILongPressGestureRecognizer *)recognizer;
@end

@interface EpgGridLabel : NSObject

@property (nonatomic, weak) id <EpgGridLabelDelegate> delegate;

@property (nonatomic, retain) ArgusProgramme *Programme;

@property (nonatomic, retain) UITableViewCell *tableViewCell;

@property (nonatomic, retain) UIView *view;
@property (nonatomic, retain) UILabel *label;

// displayed if the programme is an upcoming programme
@property (nonatomic, retain) UIImageView *iconView;

// the original size of the UILabel. we fiddle with origin and size
// when scrolling to keep the programme title visible if possible
@property (nonatomic, assign) CGRect origFrameRect;

@property (nonatomic, retain) NSDate *midnight;
@property (nonatomic, assign) NSInteger rowHeight;

// pixel padding inside the view, to push the label in a bit
@property (nonatomic, assign) NSInteger viewPadding;

-(id)initWithRowHeight:(NSInteger)_rowHeight midnight:(NSDate *)_midnight programme:(ArgusProgramme *)_Programme delegate:(id <EpgGridLabelDelegate>)_delegate;

-(UIView *)makeView;

-(void)updateColours;

-(void)resizeLabel:(CGRect)newFrame;
-(void)resetLabel;

@end


