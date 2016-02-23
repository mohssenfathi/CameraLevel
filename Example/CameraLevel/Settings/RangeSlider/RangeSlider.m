//
//  RangeSlider.m
//  CameraNoir
//
//  Created by Mohammad Fathi on 8/4/15.
//  Copyright (c) 2015 Mohammad Fathi. All rights reserved.
//

#import "RangeSlider.h"

@interface RangeSlider()

@property (strong, nonatomic) IBOutlet UIView *view;
@property (strong, nonatomic) IBOutlet UIView *track;
@property (strong, nonatomic) IBOutlet UIView *minKnob;
@property (strong, nonatomic) IBOutlet UIView *maxKnob;
@property (strong, nonatomic) IBOutlet UISlider *slider;
@property (strong, nonatomic) IBOutlet UIPanGestureRecognizer *panGestureRecognizer;

@property (strong, nonatomic) NSArray *colors;

@property (strong, nonatomic) UIColor *minColor;
@property (strong, nonatomic) UIColor *midColor;
@property (strong, nonatomic) UIColor *maxColor;
@property (strong, nonatomic) UIColor *adjustedColor;

@property (assign, nonatomic) CGFloat midRatio;
@property (strong, nonatomic) UIView *currentKnob;

@property (strong, nonatomic) CAGradientLayer *gradient;

@end

@implementation RangeSlider

- (id)initWithCoder:(NSCoder *)aDecoder{
    if ((self = [super initWithCoder:aDecoder])){
        NSString *className = NSStringFromClass([self class]);
        self.view = [[[NSBundle mainBundle] loadNibNamed:className owner:self options:nil] firstObject];
        [self addSubview:self.view];
        
        self.backgroundColor = [UIColor clearColor];
        self.view.backgroundColor = [UIColor clearColor];
        
        [self.slider setThumbImage:[UIImage imageNamed:@"knob"] forState:UIControlStateNormal];
        [self.slider setMinimumTrackImage:[UIImage new] forState:UIControlStateNormal];
        [self.slider setMaximumTrackImage:[UIImage new] forState:UIControlStateNormal];
        self.slider.thumbTintColor  = [UIColor grayColor];
        self.slider.minimumValue = 0.0;
        self.slider.maximumValue = 1.0;
        self.slider.value = 0.5;
        
//        self.minKnob.center = CGPointMake(50, CGRectGetMidY(self.frame));
//        self.maxKnob.center = CGPointMake(CGRectGetWidth(self.frame) - 50, CGRectGetMidY(self.frame));
        
        self.tolerance = 0.4;
        self.showsLimits = YES;
        self.scalesMid = YES;
        self.midRatio = 0.5;
        
        return self;
    }
    return nil;
}

- (void)layoutSubviews {

}

- (void)drawRect:(CGRect)rect {
    self.frame = rect;
    self.view.frame = self.bounds;
    [self updateSliderPositions];
}

- (void)setColors:(NSArray *)colors {
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.startPoint = CGPointMake(0, 0.5);
    gradient.endPoint   = CGPointMake(1, 0.5);
    gradient.frame = self.track.bounds;
    
    NSMutableArray *colorArray = [[NSMutableArray alloc] init];
    for (UIColor * color in colors) {
        if (![color isKindOfClass:[UIColor class]]) continue;
        [colorArray addObject:(id)color.CGColor];
    }
    
    NSMutableArray *locations = [[NSMutableArray alloc] init];
    for (NSInteger i = 1; i <= colorArray.count; i++) [locations addObject:@(1.0/colorArray.count * i)];
    
    _colors = colorArray;
    _gradient = gradient;
    
    gradient.colors = colorArray;
    gradient.locations = locations;
    
    for (id layer in self.track.layer.sublayers) [layer removeFromSuperlayer];
    [self.track.layer insertSublayer:gradient atIndex:0];
}

- (void)setShowsLimits:(BOOL)showsLimits {
    _showsLimits = showsLimits;
    self.minKnob.hidden = !showsLimits;
    self.maxKnob.hidden = !showsLimits;
    self.panGestureRecognizer.enabled = !showsLimits;
}

- (void)setKnobColor:(UIColor *)color {
    UIView *knob = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    UIView *innerView = [[UIView alloc] initWithFrame:CGRectMake(2, 2, 26, 26)];
    knob.backgroundColor = [UIColor whiteColor];
    innerView.backgroundColor = color;
    knob.layer.cornerRadius = knob.frame.size.width/2;
    knob.layer.masksToBounds = YES;
    innerView.layer.cornerRadius = innerView.frame.size.width/2;
    innerView.layer.masksToBounds = YES;
    [knob addSubview:innerView];
    UIImage *knobImage = [self imageWithView:knob];
    [self.slider setThumbImage:knobImage forState:UIControlStateNormal];
    [self.slider setThumbImage:knobImage forState:UIControlStateHighlighted];
}

- (UIImage *)imageWithView:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

- (void)setValue:(CGFloat)value {
    _value = value;
    self.slider.value = value;
}

- (void)setTolerance:(CGFloat)tolerance {
    _tolerance = tolerance;
    [self updateSliderPositions];
}

- (void)setMinColor:(UIColor *)minColor midColor:(UIColor *)midColor maxColor:(UIColor *)maxColor {
    _minColor = minColor;
    _midColor = midColor;
    _maxColor = maxColor;
    _adjustedColor = _midColor;
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.startPoint = CGPointMake(0, 0.5);
    gradient.endPoint   = CGPointMake(1, 0.5);
    gradient.frame = self.track.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)minColor.CGColor, (id)midColor.CGColor, (id)maxColor.CGColor, nil];
    for (id layer in self.track.layer.sublayers) [layer removeFromSuperlayer];
    [self.track.layer insertSublayer:gradient atIndex:0];
}

- (IBAction)handlePanGestureRecognizer:(UIPanGestureRecognizer *)sender {
    CGPoint location = [sender locationInView:self.view];

    CGFloat x = [self xPositionForSlider:self.slider];
    CGRect minFrame = CGRectMake(0, 0, x - 30.0, CGRectGetHeight(self.frame));
    CGRect maxFrame = CGRectMake(x + 30.0, 0, CGRectGetWidth(self.frame) - (x + 30.0), CGRectGetHeight(self.frame));
    if (CGRectContainsPoint(minFrame, location) || CGRectContainsPoint(maxFrame, location)) {
        CGFloat min = CGRectGetMinX(self.track.frame);
        CGFloat mid = [self xPositionForSlider:self.slider];
        CGFloat max = CGRectGetMaxX(self.track.frame);
        
        CGFloat maxTolerance = MIN((max - mid), (mid - min));
        maxTolerance = [self convertValue:maxTolerance fromMin:min max:max toMin:0 max:1];
        
        CGFloat xDiff = fabs(location.x - mid);
        self.tolerance = [self convertValue:xDiff fromMin:min max:max toMin:0 max:1];
        if (self.tolerance < 0.1) self.tolerance = 0.1;
        if (self.tolerance > maxTolerance) {
            if (self.slider.value + self.tolerance > 1.0) self.slider.value -= (self.tolerance - maxTolerance);
            else                                          self.slider.value += (self.tolerance - maxTolerance);
        }
        
        [self update];
    }
}

- (UIColor *)currentColor {
    CGFloat location = [self convertValue:_slider.value fromMin:0 max:1 toMin:0 max:_colors.count];
    
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

- (void)update {

    [self setKnobColor:[self currentColor]];
    
    if ([self.delegate respondsToSelector:@selector(rangeSlider:colorChanged:)]) {
        [self.delegate rangeSlider:self colorChanged:_adjustedColor];
    }
    if ([self.delegate respondsToSelector:@selector(rangeSlider:toleranceChanged:)]) {
        [self.delegate rangeSlider:self toleranceChanged:self.tolerance];
    }
    
    [self updateSliderPositions];
}

- (IBAction)sliderValueChanged:(UISlider *)sender {
    
    CGFloat min = sender.value - self.tolerance;
    CGFloat max = sender.value + self.tolerance;
    
    if (min < -0.1) {
        min = -0.1;
        self.tolerance = sender.value - min;
        max = sender.value + self.tolerance;
    }
    if (max > 1.1) {
        max = 1.1;
        self.tolerance = max - sender.value;
//        min = sender.value - self.tolerance;
    }
    
    if (self.tolerance < 0.1) {
        self.tolerance = 0.1;
//        min = sender.value - self.tolerance;
//        max = sender.value + self.tolerance;
    }
    
    [self update];
}

- (UIColor *)adjustBaseColor:(UIColor *)baseColor toTargetColor:(UIColor *)targetColor withIntensity:(CGFloat)intensity {
    const CGFloat *baseComponents   = CGColorGetComponents(baseColor.CGColor);
    const CGFloat *targetComponents = CGColorGetComponents(targetColor.CGColor);
    
    intensity *= 10.0;
    intensity = roundf(intensity) / 10;
    
    CGFloat r = [self convertValue:intensity fromMin:0 max:1 toMin:baseComponents[0] max:targetComponents[0]];
    CGFloat g = [self convertValue:intensity fromMin:0 max:1 toMin:baseComponents[1] max:targetComponents[1]];
    CGFloat b = [self convertValue:intensity fromMin:0 max:1 toMin:baseComponents[2] max:targetComponents[2]];
    
    return [UIColor colorWithRed:r green:g blue:b alpha:targetComponents[3]];
}

- (void)updateSliderPositions {
    CGFloat xDiff = CGRectGetWidth(self.slider.frame) * self.tolerance;
    CGFloat sliderX = [self xPositionForSlider:self.slider];
    self.minKnob.center = CGPointMake(sliderX - xDiff, CGRectGetMidY(self.frame));
    self.maxKnob.center = CGPointMake(sliderX + xDiff, CGRectGetMidY(self.frame));
}

- (NSArray *)xPositions {
    CGFloat x0 = self.minKnob.center.x;
    CGFloat x1 = [self xPositionForSlider:self.slider];
    CGFloat x2 = self.maxKnob.center.x;
    return @[@(x0), @(x1), @(x2)];
}

- (float)xPositionForSlider:(UISlider *)slider {
    float sliderRange = slider.frame.size.width - slider.currentThumbImage.size.width;
    float sliderOrigin = slider.frame.origin.x + (slider.currentThumbImage.size.width / 2.0);
    float sliderValueToPixels = (((slider.value - slider.minimumValue)/(slider.maximumValue - slider.minimumValue)) * sliderRange) + sliderOrigin;
    return sliderValueToPixels;
}

- (CGFloat)convertValue:(CGFloat)value fromMin:(CGFloat)oldMin max:(CGFloat)oldMax toMin:(CGFloat)newMin max:(CGFloat)newMax {
    CGFloat normalizedValue = (value - oldMin)/(oldMax - oldMin);
    CGFloat newValue = newMin + (normalizedValue * (newMax - newMin));
    return newValue;
}

@end
