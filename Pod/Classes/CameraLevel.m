//
//  CameraLevel.m
//  CameraNoir
//
//  Created by Mohssen Fathi on 12/4/15.
//  Copyright © 2015 Mohammad Fathi. All rights reserved.
//

#import "CameraLevel.h"
#import <CoreMotion/CoreMotion.h>

/*  
                  ^ (Pitch +)
                  |                     ^  (Roll -) CCW
            +-----------+               |
            |           |
(Yaw +) <-- |   Phone   | --> (Yaw +)
            |           |
            +-----------+               |
                  |                     v  (Roll +) CW
                  v (Pitch -)
*/
@interface CameraLevel() {
    CGFloat rollX;
    CGFloat rollY;
    
    CGFloat pitch;
    CGFloat pitchBias;
    
    BOOL rollAligned;
    BOOL pitchAligned;
    
    UIDeviceOrientation currentOrientation;
}

@property (strong, nonatomic) UIView *mainView;   // non-moving components

@property (strong, nonatomic) UIView *pitchView;  // indicator of vertical movement
@property (strong, nonatomic) NSMutableArray *pitchLayers;

@property (strong, nonatomic) UIView *rollView;   // indicator of tilt
@property (strong, nonatomic) NSMutableArray *rollLayers;

@property (strong, nonatomic) CMMotionManager *motionManager;

@end

@implementation CameraLevel

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
        return self;
    }
    return nil;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
        return self;
    }
    return nil;
}

- (void)commonInit {
    self.backgroundColor = [UIColor clearColor];
    self.usePitchBias = NO;
    
    self.lineWidth = 1.0f;
    self.lineColor = [UIColor colorWithWhite:1.0 alpha:0.75];

    self.tickWidth = 1.0f;
    self.tickColor = [UIColor colorWithWhite:1.0 alpha:0.75];
    
    self.circleWidth = 1.0f;
    self.circleColor = [UIColor colorWithWhite:1.0 alpha:0.75];
}

- (void)drawRect:(CGRect)rect {
    self.frame = rect;
    [self drawMainView];
    [self drawPitchView];
    [self drawRollView];
}


#pragma mark - Motion

- (void)start {
    if (!self.motionManager) {
        self.motionManager = [CMMotionManager new];
    }
    
    if (self.motionManager.accelerometerAvailable) {
        
        __weak typeof(self)weakSelf = self;
        
        rollX = 0.0f;
        rollY = 0.0f;
        pitch = 0.0f;
        pitchBias = 0.0f;
        
        rollAligned = NO;
        pitchAligned = NO;
        
        self.motionManager.accelerometerUpdateInterval = 0.01f;
        
        [self.motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMAccelerometerData * _Nullable accelerometerData, NSError * _Nullable error) {
            
            CGFloat k = 0.95;
            rollX = k * rollX + (1.0 - k) * accelerometerData.acceleration.x;
            rollY = k * rollY + (1.0 - k) * accelerometerData.acceleration.y;
            
            if (pitchBias == 0.0f) pitchBias = accelerometerData.acceleration.z;
            pitch = k * pitch + (1.0 - k) * accelerometerData.acceleration.z;
            
            [weakSelf updateRoll:atan2(rollX, rollY) - M_PI];
            [weakSelf updatePitch:pitch];
        }];
    }
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)stop {
    @try {
        [self.motionManager stopAccelerometerUpdates];
        [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange) name:UIDeviceOrientationDidChangeNotification object:nil];
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception.description);
    }
}

- (void)deviceOrientationDidChange {
    currentOrientation = [[UIDevice currentDevice] orientation];
}

- (CGFloat)angle:(UIDeviceOrientation)orientation {
    switch (orientation) {
        case UIDeviceOrientationPortrait:           return  0.0f;
        case UIDeviceOrientationLandscapeLeft:      return -M_PI_2;
        case UIDeviceOrientationLandscapeRight:     return  M_PI_2;
        case UIDeviceOrientationPortraitUpsideDown: return  M_PI;
        default: break;
    }
    return 0.0f;
}

- (void)updateRoll:(CGFloat)roll {
    
    CGFloat f = fabs(fmodf(roll, M_PI_2));
    if (f < 0.15) {
        for (CAShapeLayer *shapeLayer in self.rollLayers) {
            shapeLayer.strokeColor = [UIColor colorWithRed:1.0 - f green:0.8 - f blue:0.0 alpha:1.0].CGColor;
        }
        rollAligned = YES;
    } else if (rollAligned) {
        for (CAShapeLayer *shapeLayer in self.rollLayers) {
            shapeLayer.strokeColor = [UIColor whiteColor].CGColor;
        }
        rollAligned = NO;
    }
    
    self.rollView.transform = CGAffineTransformMakeRotation(roll);
}

- (void)updatePitch:(CGFloat)p {
    
    if (self.usePitchBias) p -= pitchBias;
    
    if (fabs(p) < 0.15) {
        for (CAShapeLayer *shapeLayer in self.pitchLayers) {
            shapeLayer.strokeColor = [UIColor colorWithRed:1.0 - fabs(p) green:0.8 - fabs(p) blue:0.0 alpha:1.0].CGColor;
        }
        pitchAligned = YES;
    } else if (pitchAligned) {
        for (CAShapeLayer *shapeLayer in self.pitchLayers) {
            shapeLayer.strokeColor = [UIColor whiteColor].CGColor;
        }
        pitchAligned = NO;
    }
    
    CGAffineTransform translation = CGAffineTransformMakeTranslation(0, p * 150.0f);
    CGAffineTransform rotation = CGAffineTransformMakeRotation([self angle:currentOrientation]);
    self.pitchView.transform = CGAffineTransformConcat(translation, rotation);
}

- (void)recenterPitch {
    self.usePitchBias = YES;
    pitchBias = 0.0f;
}


#pragma mark - Drawing

- (void)redraw {
    [self.mainView removeFromSuperview];
    [self.pitchView removeFromSuperview];
    self.mainView = nil;
    self.pitchView = nil;
    [self drawMainView];
    [self drawPitchView];
}

- (void)drawMainView {
    
    if (self.mainView) return;
    self.mainView = [[UIView alloc] initWithFrame:self.bounds];
    
    // Circle
    CGFloat diameter = CGRectGetWidth(self.frame)/2.0f;
    CGRect circleRect = CGRectMake(CGRectGetMidX(self.frame) - diameter/2.0f, CGRectGetMidY(self.frame) - diameter/2.0f, diameter, diameter);
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:circleRect];
    
    CAShapeLayer *circleLayer = [[CAShapeLayer alloc] init];
    circleLayer.path = circlePath.CGPath;
    circleLayer.strokeColor = self.circleColor.CGColor;
    circleLayer.fillColor = [UIColor clearColor].CGColor;
    circleLayer.lineWidth = self.circleWidth;
    
    CAShapeLayer *circleLayerOutline = [[CAShapeLayer alloc] init];
    circleLayerOutline.path = circlePath.CGPath;
    circleLayerOutline.strokeColor = [UIColor colorWithWhite:0.0 alpha:0.75].CGColor;
    circleLayerOutline.fillColor = [UIColor clearColor].CGColor;
    circleLayerOutline.lineWidth = self.circleWidth + 0.5;
    
    [self.mainView.layer addSublayer:circleLayerOutline];
    [self.mainView.layer addSublayer:circleLayer];

    
    // Plus
    [self drawLineWithLineWidth:self.lineWidth lineColor:self.lineColor
                 fromStartPoint:CGPointMake(self.center.x, self.center.y - 7.0f)
                     toEndPoint:CGPointMake(self.center.x, self.center.y + 7.0f)
                         inView:self.mainView];

    [self drawLineWithLineWidth:self.lineWidth lineColor:self.lineColor
                 fromStartPoint:CGPointMake(self.center.x - 7.0f, self.center.y)
                     toEndPoint:CGPointMake(self.center.x + 7.0f, self.center.y)
                         inView:self.mainView];
    
    // Edge Dashes
    [self drawLineWithLineWidth:self.tickWidth lineColor:self.tickColor
                 fromStartPoint:CGPointMake(self.center.x - diameter/2.0f - 5.0f, self.center.y)
                     toEndPoint:CGPointMake(self.center.x - diameter/2.0f + 5.0f, self.center.y)
                         inView:self.mainView];
    
    [self drawLineWithLineWidth:self.tickWidth lineColor:self.tickColor
                 fromStartPoint:CGPointMake(self.center.x + diameter/2.0f - 5.0f, self.center.y)
                     toEndPoint:CGPointMake(self.center.x + diameter/2.0f + 5.0f, self.center.y)
                         inView:self.mainView];
    
    [self drawLineWithLineWidth:self.tickWidth lineColor:self.tickColor
                 fromStartPoint:CGPointMake(self.center.x, self.center.y - diameter/2.0f - 5.0f)
                      toEndPoint:CGPointMake(self.center.x, self.center.y - diameter/2.0f + 5.0f)
                          inView:self.mainView];
    
    [self drawLineWithLineWidth:self.tickWidth lineColor:self.tickColor
                 fromStartPoint:CGPointMake(self.center.x, self.center.y + diameter/2.0f - 5.0f)
                     toEndPoint:CGPointMake(self.center.x, self.center.y + diameter/2.0f + 5.0f)
                         inView:self.mainView];
    
    [self addSubview:self.mainView];
}

- (void)drawPitchView {
    if (self.pitchView) return;
    self.pitchView = [[UIView alloc] initWithFrame:self.bounds];
    self.pitchView.center = self.center;
    
    CGFloat verticalGap = 50.0f;
    
    [self drawLineWithLineWidth:self.lineWidth lineColor:self.lineColor
                 fromStartPoint:CGPointMake(self.center.x - 50, self.center.y - verticalGap * 3)
                     toEndPoint:CGPointMake(self.center.x + 50, self.center.y - verticalGap * 3)
                         inView:self.pitchView];
    
    [self drawLineWithLineWidth:self.lineWidth lineColor:self.lineColor
                 fromStartPoint:CGPointMake(self.center.x - 40, self.center.y - verticalGap * 2)
                     toEndPoint:CGPointMake(self.center.x + 40, self.center.y - verticalGap * 2)
                         inView:self.pitchView];
    
    [self drawLineWithLineWidth:self.lineWidth lineColor:self.lineColor
                 fromStartPoint:CGPointMake(self.center.x - 30, self.center.y - verticalGap * 1)
                     toEndPoint:CGPointMake(self.center.x + 30, self.center.y - verticalGap * 1)
                         inView:self.pitchView];
    
    [self drawLineWithLineWidth:self.lineWidth lineColor:self.lineColor
                 fromStartPoint:CGPointMake(self.center.x - 50, self.center.y + verticalGap * 3)
                     toEndPoint:CGPointMake(self.center.x + 50, self.center.y + verticalGap * 3)
                         inView:self.pitchView];
    
    [self drawLineWithLineWidth:self.lineWidth lineColor:self.lineColor
                 fromStartPoint:CGPointMake(self.center.x - 40, self.center.y + verticalGap * 2)
                     toEndPoint:CGPointMake(self.center.x + 40, self.center.y + verticalGap * 2)
                          inView:self.pitchView];
    
    [self drawLineWithLineWidth:self.lineWidth lineColor:self.lineColor
                 fromStartPoint:CGPointMake(self.center.x - 30, self.center.y + verticalGap * 1)
                     toEndPoint:CGPointMake(self.center.x + 30, self.center.y + verticalGap * 1)
                         inView:self.pitchView];
    
    CGFloat diameter = 25.0f;
    CGRect circleRect = CGRectMake(self.pitchView.center.x - diameter/2.0, self.pitchView.center.y - diameter/2.0, diameter, diameter);
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:circleRect];
    
    CAShapeLayer *circleLayer = [[CAShapeLayer alloc] init];
    circleLayer.path = circlePath.CGPath;
    circleLayer.strokeColor = self.circleColor.CGColor;
    circleLayer.fillColor = [UIColor clearColor].CGColor;
    circleLayer.lineWidth = self.circleWidth;
    
    CAShapeLayer *circleLayerOutline = [[CAShapeLayer alloc] init];
    circleLayerOutline.path = circlePath.CGPath;
    circleLayerOutline.strokeColor = [UIColor colorWithWhite:0.0 alpha:0.75].CGColor;
    circleLayerOutline.fillColor = [UIColor clearColor].CGColor;
    circleLayerOutline.lineWidth = self.circleWidth + 0.5;
    
    [self.pitchView.layer addSublayer:circleLayerOutline];
    [self.pitchView.layer addSublayer:circleLayer];
    
    self.pitchLayers = [[NSMutableArray alloc] init];
    [self.pitchLayers addObject:circleLayer];
    
    [self addSubview:self.pitchView];
}

- (void)drawRollView {
    if (self.rollView) return;
    
    self.rollView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), 10.0f)];
    self.rollView.center = self.center;
    
    CGFloat gap = 8.0f;
    
    CGPoint p0 = CGPointMake(CGRectGetWidth(self.frame) / 8.0f           , 5.0f);
    CGPoint p1 = CGPointMake(CGRectGetWidth(self.frame) / 4.0f  - gap    , 5.0f);
    CGPoint p2 = CGPointMake(CGRectGetWidth(self.frame) / 4.0f  + gap    , 5.0f);
    CGPoint p3 = CGPointMake(CGRectGetWidth(self.frame) / 2.0f  - 3 * gap, 5.0f);
    CGPoint p4 = CGPointMake(CGRectGetWidth(self.frame) / 2.0f  + 3 * gap, 5.0f);
    CGPoint p5 = CGPointMake(CGRectGetWidth(self.frame) * 0.75f - gap    , 5.0f);
    CGPoint p6 = CGPointMake(CGRectGetWidth(self.frame) * 0.75f + gap    , 5.0f);
    CGPoint p7 = CGPointMake(CGRectGetWidth(self.frame) * 0.875f         , 5.0f);
    
    CAShapeLayer *rollLayer;
    self.rollLayers = [[NSMutableArray alloc] init];
    
    rollLayer = [self drawLineWithLineWidth:self.lineWidth lineColor:self.lineColor
                             fromStartPoint:p0 toEndPoint:p1 inView:self.rollView].firstObject;
    [self.rollLayers addObject:rollLayer];
    
    rollLayer = [self drawLineWithLineWidth:self.lineWidth lineColor:self.lineColor
                             fromStartPoint:p2 toEndPoint:p3 inView:self.rollView].firstObject;
    [self.rollLayers addObject:rollLayer];
    
    rollLayer = [self drawLineWithLineWidth:self.lineWidth lineColor:self.lineColor
                             fromStartPoint:p4 toEndPoint:p5 inView:self.rollView].firstObject;
    [self.rollLayers addObject:rollLayer];
    
    rollLayer = [self drawLineWithLineWidth:self.lineWidth lineColor:self.lineColor
                             fromStartPoint:p6 toEndPoint:p7 inView:self.rollView].firstObject;
    [self.rollLayers addObject:rollLayer];
    
    [self addSubview:self.rollView];
}


#pragma mark - Drawing Helpers

- (void)drawLineFromStartPoint:(CGPoint)startPoint toEndPoint:(CGPoint)endPoint inView:(UIView *)view {
    [self drawLineWithLineWidth:1.0f fromStartPoint:startPoint toEndPoint:endPoint inView:view];
}

- (NSArray *)drawLineWithLineWidth:(CGFloat)lineWidth fromStartPoint:(CGPoint)startPoint toEndPoint:(CGPoint)endPoint inView:(UIView *)view {
    return [self drawLineWithLineWidth:lineWidth lineColor:[UIColor colorWithWhite:1.0 alpha:0.75] fromStartPoint:startPoint toEndPoint:endPoint inView:view];
}

- (NSArray *)drawLineWithLineWidth:(CGFloat)lineWidth lineColor:(UIColor *)lineColor fromStartPoint:(CGPoint)startPoint toEndPoint:(CGPoint)endPoint inView:(UIView *)view {
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:startPoint];
    [path addLineToPoint:endPoint];
    
    CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
    shapeLayer.path = path.CGPath;
    shapeLayer.strokeColor = lineColor.CGColor;
    shapeLayer.lineWidth = lineWidth;
    shapeLayer.lineCap = @"round";
    
    CAShapeLayer *shapeLayerOutline = [[CAShapeLayer alloc] init];
    shapeLayerOutline.path = path.CGPath;
    shapeLayerOutline.strokeColor = [UIColor colorWithWhite:0.0 alpha:0.75].CGColor;
    shapeLayerOutline.lineWidth = lineWidth + 0.5f;
    shapeLayerOutline.lineCap = @"round";
    
    [view.layer addSublayer:shapeLayerOutline];
    [view.layer addSublayer:shapeLayer];
    
    return @[shapeLayer, shapeLayerOutline];
}

@end
