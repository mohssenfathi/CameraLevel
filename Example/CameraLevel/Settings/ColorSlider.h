//
//  ColorSlider.h
//  CameraLevel
//
//  Created by Mohssen Fathi on 2/23/16.
//  Copyright © 2016 Mohssen Fathi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ColorSlider;

@protocol ColorSliderDelegate <NSObject>

- (void)colorSlider:(ColorSlider *)colorSlider colorChanged:(UIColor *)color;
- (void)colorSliderReleased:(ColorSlider *)colorSlider;

@end

@interface ColorSlider : UIControl

- (void)setColors:(NSArray *)colors;

@property (weak, nonatomic) id<ColorSliderDelegate> delegate;

@end
