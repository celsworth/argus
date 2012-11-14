//
//  LoadingSpinner.h
//  Argus
//
//  Created by Chris Elsworth on 02/04/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LoadingSpinnerViewController.h"

@interface LoadingSpinner : NSObject

-(void)presentOnView:(UIView *)view;
-(void)setProgress:(CGFloat)pctDone;
-(void)fadeOut;

@end
