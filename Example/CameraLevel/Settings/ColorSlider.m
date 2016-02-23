//
//  ColorSlider.m
//  CameraLevel
//
//  Created by Mohssen Fathi on 2/23/16.
//  Copyright © 2016 Mohssen Fathi. All rights reserved.
//

#import "ColorSlider.h"

@interface ColorSlider()

@property (strong, nonatomic) CAGradientLayer *gradient;
@property (strong, nonatomic) UIView *track;
@property (strong, nonatomic) UIView *knob;
@property (strong, nonatomic) NSArray *colors;
@property (strong, nonatomic) UIPanGestureRecognizer *pan;

@end

@implementation ColorSlider


- (void)drawRect:(CGRect)rect {
    self.frame = rect;
    [self draw];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.frame = frame;
        [self commonInit];
        [self draw];
    }
    return self;
}

- (void)commonInit {
    self.pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self addGestureRecognizer:self.pan];
}

- (void)draw {
    [self drawTrack];
    [self drawKnob];
}

- (void)handlePan:(UIPanGestureRecognizer *)pan {
    CGPoint location = [pan locationInView:self];
    CGRect rect = CGRectMake(location.x - 30, location.y - 30, 60, 60);
    if (CGRectContainsPoint(rect, self.knob.center)) {
        if (location.x < 10 || location.x > CGRectGetWidth(self.frame) - 20) return;
        self.knob.center = CGPointMake(location.x, self.track.center.y);
        [self updateKnobColor];
        if ([self.delegate respondsToSelector:@selector(colorSlider:colorChanged:)]) {
            [self.delegate colorSlider:self colorChanged:[self currentColor]];
        }
    }
    
    if (pan.state == UIGestureRecognizerStateEnded) {
        if ([self.delegate respondsToSelector:@selector(colorSliderReleased:)]) {
            [self.delegate colorSliderReleased:self];
        }
    }
}

- (void)setColors:(NSArray *)colors {
    NSMutableArray *colorArray = [[NSMutableArray alloc] init];
    for (UIColor * color in colors) {
        if (![color isKindOfClass:[UIColor class]]) continue;
        [colorArray addObject:(id)color.CGColor];
    }
    
    _colors = colorArray;

    [self drawTrack];
}

- (void)drawTrack {
    
    if (self.track) {
        [self.track removeFromSuperview];
        self.track = nil;
    }
    
    self.track = [[UIView alloc] initWithFrame:CGRectMake(10, CGRectGetHeight(self.frame)/2 - 1, CGRectGetWidth(self.frame) - 20, 2)];
    [self addSubview:self.track];
    
    NSMutableArray *locations = [[NSMutableArray alloc] init];
    for (NSInteger i = 1; i <= _colors.count; i++) [locations addObject:@(1.0/_colors.count * i)];
    
    self.gradient = [CAGradientLayer layer];
    _gradient.startPoint = CGPointMake(0, 0.5);
    _gradient.endPoint   = CGPointMake(1, 0.5);
    _gradient.frame = self.track.bounds;
    _gradient.locations = locations;
    _gradient.colors = self.colors;
    
    [self.track.layer insertSublayer:_gradient atIndex:0];
    [self bringSubviewToFront:self.knob];
}

- (void)drawKnob {
    if (self.knob) {
        [self.knob removeFromSuperview];
        self.knob = nil;
    }
    
    self.knob = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
    _knob.center = self.center;
    _knob.backgroundColor = [UIColor whiteColor];
    _knob.layer.cornerRadius = _knob.frame.size.width/2;
    _knob.layer.masksToBounds = YES;
    [self addSubview:_knob];
}

- (void)updateKnobColor {
    [self setKnobColor:[self currentColor]];
}

- (UIColor *)currentColor {
    CGFloat location = [self convertValue:_knob.center.x fromMin:10 max:CGRectGetWidth(self.frame) - 20 toMin:0 max:_colors.count];
    
    CGColorRef lower = (__bridge CGColorRef)([self.colors objectAtIndex:floor(location) - 1]);
    CGColorRef upper = (__bridge CGColorRef)([self.colors objectAtIndex: ceil(location) - 1]);
    const CGFloat *lowerComponents = CGColorGetComponents(lower);
    const CGFloat *upperComponents = CGColorGetComponents(upper);
    
    CGFloat value = location - floorf(location);
    CGFloat r = [self convertValue:value fromMin:0 max:1 toMin:lowerComponents[0] max:upperComponents[0]];
    CGFloat g = [self convertValue:value fromMin:0 max:1 toMin:lowerComponents[1] max:upperComponents[1]];
    CGFloat b = [self convertValue:value fromMin:0 max:1 toMin:lowerComponents[2] max:upperComponents[2]];
    
    return [UIColor colorWithRed:r green:g blue:b alpha:1.0];
}

- (void)setKnobColor:(UIColor *)color {
    _knob.backgroundColor = color;
}

- (CGFloat)convertValue:(CGFloat)value fromMin:(CGFloat)oldMin max:(CGFloat)oldMax toMin:(CGFloat)newMin max:(CGFloat)newMax {
    CGFloat normalizedValue = (value - oldMin)/(oldMax - oldMin);
    CGFloat newValue = newMin + (normalizedValue * (newMax - newMin));
    return newValue;
}

@end
