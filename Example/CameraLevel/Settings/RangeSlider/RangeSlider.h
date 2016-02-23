//
//  RangeSlider.h
//  CameraNoir
//
//  Created by Mohammad Fathi on 8/4/15.
//  Copyright (c) 2015 Mohammad Fathi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RangeSlider;

typedef enum {
    SliderRangeMin = 0,
    SliderRangeMid,
    SliderRangeMax,
    SliderRangeNone
} SliderRange;

@protocol RangeSliderDelegate <NSObject>

- (void)rangeSlider:(RangeSlider *)rangeSlider colorChanged:(UIColor *)color;
- (void)rangeSlider:(RangeSlider *)rangeSlider toleranceChanged:(CGFloat)tolerance;

@end

@interface RangeSlider : UIView

@property (assign, nonatomic) BOOL showsLimits;
@property (assign, nonatomic) BOOL scalesMid;
@property (assign, nonatomic) CGFloat value;
@property (assign, nonatomic) CGFloat tolerance;

@property (weak  , nonatomic) id<RangeSliderDelegate> delegate;

- (void)setMinColor:(UIColor *)minColor midColor:(UIColor *)midColor maxColor:(UIColor *)maxColor;
- (void)setMinKnob:(UIView *)minKnob;
- (void)setMaxKnob:(UIView *)maxKnob;
- (void)setKnobColor:(UIColor *)color;

- (void)setColors:(NSArray *)colors;

- (void)update;


@end
