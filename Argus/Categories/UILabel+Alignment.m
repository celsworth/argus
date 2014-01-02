//
//  UILabel+Alignment.m
//  Argus
//
//  Created by Chris Elsworth on 29/03/2012.
//  Copyright (c) 2012 Elsworth IT Consulting Ltd. All rights reserved.
//

#import "UILabel+Alignment.h"

@implementation UILabel (Alignment)

-(void)topAlign
{
	[self topAlignUsingWidth:self.frame.size.width];
}

-(void)topAlignUsingWidth:(CGFloat)width
{
	CGSize constrain = CGSizeMake(width, MAXFLOAT);
	
	CGSize tmp;
	if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
	{
		// iOS6 and below; we know this is deprecated so ignore the warning
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
		tmp = [self.text sizeWithFont:self.font
					constrainedToSize:constrain
						lineBreakMode:UILineBreakModeWordWrap];
#pragma clang diagnostic pop
	}
	else
	{
		// iOS7+
		CGRect tmp2 = [self.text boundingRectWithSize:constrain
											  options:NSStringDrawingUsesLineFragmentOrigin
										   attributes:@{NSFontAttributeName:self.font}
											  context:nil];
		tmp = tmp2.size;
	}
	
	CGRect new = self.frame;
	new.size.height = tmp.height+1; // +1 seems to fix some last lines not fitting in.. silly
	
	[self setFrame:new];
}
@end
