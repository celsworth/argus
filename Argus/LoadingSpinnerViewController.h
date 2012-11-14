//
//  LoadingSpinnerViewController.h
//  Argus
//
//  Created by Chris Elsworth on 19/09/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoadingSpinnerViewController : UIViewController

@property (nonatomic, weak) IBOutlet UIProgressView *progressView;
@property (nonatomic, weak) IBOutlet UIView *pleaseWait;

@end
