//
//  SettingsCell.m
//  Water
//
//  Created by Mohssen Fathi on 1/7/16.
//  Copyright © 2016 Mohssen Fathi. All rights reserved.
//

#import "SliderCell.h"
#import "ColorSlider.h"

@interface SliderCell() <ColorSliderDelegate>

@end

@implementation SliderCell

- (void)awakeFromNib {
    [self.slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.slider addTarget:self action:@selector(sliderReleased:)     forControlEvents:UIControlEventTouchUpInside];
    
    self.color = NO;
    self.colorSlider.delegate = self;
    
    if ([self.dataSource respondsToSelector:@selector(sliderCellPropertyName:)]) {
        self.propertyName = [self.dataSource sliderCellPropertyName:self];
    }
}

- (void)setColor:(BOOL)color {
    _color = color;
    
    self.slider.hidden = color;
    self.valueLabel.hidden = color;
    self.colorSlider.hidden = !color;

    if (color) {
        [self.colorSlider setColors:@[[UIColor redColor],
                                      [UIColor orangeColor],
                                      [UIColor yellowColor],
                                      [UIColor greenColor],
                                      [UIColor cyanColor],
                                      [UIColor blueColor],
                                      [UIColor magentaColor],
                                      [UIColor purpleColor]]];
    }
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {

    }
    return self;
}

- (void)setPropertyName:(NSString *)propertyName {
    _propertyName = propertyName;
    
    self.titleLabel.text = [self.dataSource sliderCellPropertyName:self];
    
    if ([self.dataSource respondsToSelector:@selector(sliderCellValuesForSlider:)]) {
        NSDictionary *values = [self.dataSource sliderCellValuesForSlider:self];
        
        if ([values[@"type"] isEqualToString:@"number"]) {
            self.slider.minimumValue = [values[@"min"] floatValue];
            self.slider.maximumValue = [values[@"max"] floatValue];
            self.slider.value        = [values[@"mid"] floatValue];
            [self sliderValueChanged:_slider];
        }
        else if ([values[@"type"] isEqualToString:@"color"]) {
            self.color = YES;
        }
    }
}

- (void)sliderValueChanged:(UISlider *)slider {
    if ([self.delegate respondsToSelector:@selector(sliderCell:sliderValueChanged:)]) {
        [self.delegate sliderCell:self sliderValueChanged:self.slider];
    }
    
    self.valueLabel.text = [NSString stringWithFormat:@"%.1f",slider.value];
}

- (void)sliderReleased:(UISlider *)slider {
    if ([self.delegate respondsToSelector:@selector(sliderCell:sliderReleased:)]) {
        [self.delegate sliderCell:self sliderReleased:self.slider];
    }
}


#pragma mark - ColorSlider Delegate

- (void)colorSliderReleased:(ColorSlider *)colorSlider {
    if ([self.delegate respondsToSelector:@selector(sliderCell:sliderReleased:)]) {
        [self.delegate sliderCell:self sliderReleased:self.slider]; // Useless
    }
}

- (void)colorSlider:(ColorSlider *)colorSlider colorChanged:(UIColor *)color {
    if ([self.delegate respondsToSelector:@selector(sliderCell:sliderColorChanged:)]) {
        [self.delegate sliderCell:self sliderColorChanged:color];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
