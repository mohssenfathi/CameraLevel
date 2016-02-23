//
//  GradientView.m
//  Faded
//
//  Created by Sergey Gorbachev on 6/19/13.
//  Copyright (c) 2013 Rosberry. All rights reserved.
//

#import "GradientView.h"

@implementation GradientView

- (void)dealloc {
    self.gradientColor = nil;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    self.gradientColor = [UIColor whiteColor];
}

-(void)setGradientColor:(UIColor *)gradientColor {
    _gradientColor = gradientColor;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    
	NSArray* colors1 = [[NSArray alloc] initWithObjects:
                        (id)[UIColor colorWithRed:1.0 green:0 blue:0 alpha:1.0].CGColor,
                        (id)self.gradientColor.CGColor,
                        (id)[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0].CGColor,
                        nil];
    
	CGGradientRef myGradient1 = CGGradientCreateWithColors(space, (__bridge CFArrayRef)colors1, NULL);
	CGContextDrawLinearGradient(ctx, myGradient1, CGPointZero, CGPointMake(rect.size.width, 0), 0);
	CGGradientRelease(myGradient1);
	CGColorSpaceRelease(space);
}

@end
