//
//  CameraViewController.m
//  CameraLevel
//
//  Created by Mohssen Fathi on 2/23/16.
//  Copyright © 2016 Mohssen Fathi. All rights reserved.
//

#import "CameraViewController.h"
#import "CameraLevel.h"
#import "SettingsViewController.h"
@import AVFoundation;

@interface CameraViewController ()

@property (weak, nonatomic) IBOutlet CameraLevel *cameraLevel;
@property (weak, nonatomic) IBOutlet UIButton *recenterButton;
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;

@property (strong, nonatomic) AVCaptureSession *session;
@property (strong, nonatomic) AVCaptureDevice *device;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;

@end

@implementation CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupCamera];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self startCamera];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopCamera];
}

- (void)viewDidLayoutSubviews {
    self.previewLayer.frame = self.view.bounds;
}

- (void)setupCamera {

    self.session = [AVCaptureSession new];
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];

    self.previewLayer.frame = self.view.bounds;
    [self.view.layer insertSublayer:self.previewLayer atIndex:0];
    
    NSError *error;
    AVCaptureDeviceInput *input = [[AVCaptureDeviceInput alloc] initWithDevice:self.device error:&error];
    if (error) {
        NSLog(@"Error: %@", error.description);
        return;
    }
    
    if ([self.session canAddInput:input]) {
        [self.session addInput:input];
    }

}

- (void)startCamera {
    [self.session startRunning];
    [self.cameraLevel start];
}

- (void)stopCamera {
    [self.session stopRunning];
    [self.cameraLevel stop];
}


#pragma mark - Actions

- (IBAction)recenterButtonPressed:(UIButton *)sender {
    [self.cameraLevel recenterPitch];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - Navigation

-(IBAction)prepareForUnwind:(UIStoryboardSegue *)segue {
    [UIView animateWithDuration:0.35f animations:^{
        self.recenterButton.alpha = 1.0;
        self.settingsButton.alpha = 1.0;
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"settings"]) {
        SettingsViewController *settingsViewController = (SettingsViewController *)segue.destinationViewController;
        settingsViewController.cameraLevel = self.cameraLevel;
        [UIView animateWithDuration:0.35f animations:^{
            self.recenterButton.alpha = 0.0;
            self.settingsButton.alpha = 0.0;
        }];
    }
}

@end
