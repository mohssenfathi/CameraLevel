# CameraLevel

[![CI Status](http://img.shields.io/travis/Mohssen Fathi/CameraLevel.svg?style=flat)](https://travis-ci.org/Mohssen Fathi/CameraLevel)
[![Version](https://img.shields.io/cocoapods/v/CameraLevel.svg?style=flat)](http://cocoapods.org/pods/CameraLevel)
[![License](https://img.shields.io/cocoapods/l/CameraLevel.svg?style=flat)](http://cocoapods.org/pods/CameraLevel)
[![Platform](https://img.shields.io/cocoapods/p/CameraLevel.svg?style=flat)](http://cocoapods.org/pods/CameraLevel)

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

<br/>

CameraLevel is a UIView subclass. It can be create with initWithFrame or in Interface Builder

To start and stop the camera receiving accelerometer data, use:

```objective-c
    [self.cameraLevel start];

    [self.cameraLevel stop];
```
, respectively.

<br/>

By default the level sets it's vertical center (for pitch) at the position where the phone is perpendicular to the ground. To set the default center to the devices current position, call:

```objective-c
[self.cameraLevel recenterPitch];
```

<br/>

There are a few customizable options for the level:
<br/>
The pitch indicator lines:

```objective-c
self.cameraLevel.lineWidth = 2.0f;
self.cameraLevel.lineColor = [UIColor redColor];
```

The outer and inner circles:

```objective-c
self.cameraLevel.circleWidth = 1.0f;
self.cameraLevel.circleColor = [UIColor greenColor];
```

The tick marks along the outer circle:

```objective-c
self.cameraLevel.tickWidth = 4.0f;
self.cameraLevel.tickColor = [UIColor orange];
```

To apply changes made to the levels properties you must call:
```objective-c
[self.cameraLevel redraw];
```

<br/>

![Camera Level](https://github.com/mohssenfathi/CameraLevel/blob/master/Screenshots/level.PNG)
![Customization](https://github.com/mohssenfathi/CameraLevel/blob/master/Screenshots/settings.PNG)

## Requirements

## Installation

CameraLevel is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "CameraLevel"
```

## ToDo

1. Reduce the amount of drawing needed to change properties. Remove 'redraw' method.
2. Add more customization options
3. Add modular components, to be able to customize the indicators in the level.

## Author

Mohssen Fathi, mmohssenfathi@gmail.com

## License

CameraLevel is available under the MIT license. See the LICENSE file for more info.
