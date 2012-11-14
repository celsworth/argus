//
//  EpgGridCalendarPickerVC.h
//  Argus
//
//  Created by Chris Elsworth on 07/04/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TKCalendarMonthView.h"

@interface EpgGridCalendarPickerVC : UIViewController <TKCalendarMonthViewDelegate>

@property (nonatomic, retain) TKCalendarMonthView *cal;
@property (nonatomic, weak) id <TKCalendarMonthViewDelegate> delegate;

@property (nonatomic, weak) UIPopoverController *popoverController;
@end
