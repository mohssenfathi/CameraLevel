//
//  SettingsViewController.m
//  Water
//
//  Created by Mohssen Fathi on 1/6/16.
//  Copyright © 2016 Mohssen Fathi. All rights reserved.
//

#import "SettingsViewController.h"
#import "SliderCell.h"
#import "ColorSlider.h"

@interface SettingsViewController () <UITableViewDataSource, UITableViewDelegate,
                                      SliderCellDelegate, SliderCellDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)closeButtonPressed:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - UITableView 
#pragma mark DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 6;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 75.0;
}

- (SliderCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SliderCell *cell = (SliderCell *)[tableView dequeueReusableCellWithIdentifier:@"sliderCell" forIndexPath:indexPath];

    cell.delegate = self;
    cell.dataSource = self;
    
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    
    return cell;
}

#pragma mark Delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(SliderCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        cell.propertyName = @"lineWidth";
        cell.titleLabel.text = @"Line Width";
    }
    else if (indexPath.row == 1) {
        cell.propertyName = @"lineColor";
        cell.titleLabel.text = @"Line Color";
    }
    else if (indexPath.row == 2) {
        cell.propertyName = @"tickWidth";
        cell.titleLabel.text = @"Tick Width";
    }
    else if (indexPath.row == 3) {
        cell.propertyName = @"tickColor";
        cell.titleLabel.text = @"Tick Color";
    }
    else if (indexPath.row == 4) {
        cell.propertyName = @"circleWidth";
        cell.titleLabel.text = @"Circle Width";
    }
    else if (indexPath.row == 5) {
        cell.propertyName = @"circleColor";
        cell.titleLabel.text = @"Circle Color";
    }
}


#pragma mark - ColorSlider
#pragma mark Delegate

- (void)colorSlider:(ColorSlider *)colorSlider colorChanged:(UIColor *)color {
}

- (void)colorSliderReleased:(ColorSlider *)colorSlider {
}

#pragma mark - SliderCell 
#pragma mark DataSource
- (NSDictionary *)sliderCellValuesForSlider:(SliderCell *)sliderCell {
    NSIndexPath *indexPath = [self indexPathForCell:sliderCell];
    CGFloat min, mid, max;
    if (!(indexPath.row % 2)) {
        min = 0.0; mid = self.cameraLevel.lineWidth; max = 3.0;
        return @{@"type":@"number", @"min":@(min), @"mid":@(mid), @"max":@(max)};
    } else {
        return @{@"type":@"color"};
    }
    
    return nil;
}

- (NSString *)sliderCellPropertyName:(SliderCell *)sliderCell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sliderCell];
    switch (indexPath.row) {
        case 0: return @"Line Width";
        case 1: return @"Line Color";
        case 2: return @"Tick Width";
        case 3: return @"Tick Color";
        case 4: return @"Circle Width";
        case 5: return @"Circle Color";
        default: break;
    }
    return @"";
}


#pragma mark Delegate

- (void)sliderCell:(SliderCell *)sliderCell sliderValueChanged:(UISlider *)slider {
    [self.cameraLevel setValue:@(slider.value) forKey:sliderCell.propertyName];
}

- (void)sliderCell:(SliderCell *)sliderCell sliderColorChanged:(UIColor *)color {
    [self.cameraLevel setValue:color forKey:sliderCell.propertyName];
}

- (void)sliderCell:(SliderCell *)sliderCell sliderReleased:(UISlider *)slider {
    [self.cameraLevel redraw];
}

- (NSIndexPath *)indexPathForCell:(SliderCell *)cell {
    CGPoint pointInTable = [cell convertPoint:cell.bounds.origin toView:_tableView];
    return [_tableView indexPathForRowAtPoint:pointInTable];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
