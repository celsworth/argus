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
	CGSize max = CGSizeMake(width, MAXFLOAT); 
	CGSize exp = [self.text sizeWithFont:self.font constrainedToSize:max lineBreakMode:self.lineBreakMode];
	CGRect new = self.frame;
	new.size.height = exp.height;
	[self setFrame:new];	
}
@end
