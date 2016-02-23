//
//  CameraLevel.h
//  CameraNoir
//
//  Created by Mohssen Fathi on 12/4/15.
//  Copyright © 2015 Mohammad Fathi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CameraLevel : UIView

/*  Using pitch bias will cancluate initial pitch offset at 
    launch (or recenterPitch) then update pitch based off this value */
@property (assign, nonatomic) BOOL usePitchBias;

/* set current pitch as base pitch value */
- (void)recenterPitch;

/* Starts generating motion data. Call start when view appears. */
- (void)start;

/* Stops generating motion data. Think invalidate. Stop should be called when view disappears. */
- (void)stop;

/* Must be called to update view after changing properties. */
- (void)redraw;

@property (nonatomic) UIColor *circleColor;
@property (nonatomic) CGFloat  circleWidth;

@property (nonatomic) UIColor *tickColor;
@property (nonatomic) CGFloat  tickWidth;

@property (nonatomic) UIColor *lineColor;
@property (nonatomic) CGFloat  lineWidth;

@end
