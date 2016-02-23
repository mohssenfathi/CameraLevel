//
//  SettingsCell.h
//  Water
//
//  Created by Mohssen Fathi on 1/7/16.
//  Copyright © 2016 Mohssen Fathi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SliderCell;
@class ColorSlider;

@protocol SliderCellDelegate <NSObject>
@optional
- (void)sliderCell:(SliderCell *)sliderCell sliderValueChanged:(UISlider *)slider;
- (void)sliderCell:(SliderCell *)sliderCell sliderColorChanged:(UIColor *)color;
- (void)sliderCell:(SliderCell *)sliderCell sliderReleased:(UISlider *)slider;
@end

@protocol SliderCellDataSource <NSObject>
- (NSDictionary *)sliderCellValuesForSlider:(SliderCell *)sliderCell;  // @{min:x, mid:y, max:z}
- (NSString *)sliderCellPropertyName:(SliderCell *)sliderCell;
@end

@interface SliderCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *valueLabel;
@property (strong, nonatomic) IBOutlet UISlider *slider;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet ColorSlider *colorSlider;

@property (strong, nonatomic) NSString *propertyName;

@property (nonatomic) BOOL color;

@property (weak, nonatomic) id<SliderCellDelegate>   delegate;
@property (weak, nonatomic) id<SliderCellDataSource> dataSource;

@end
