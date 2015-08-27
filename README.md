# FSPhotoBrowser

[![CI Status](http://img.shields.io/travis/DevDivinity/FSPhotoBrowser.svg?style=flat)](https://travis-ci.org/DevDivinity/FSPhotoBrowser)
[![Version](https://img.shields.io/cocoapods/v/FSPhotoBrowser.svg?style=flat)](http://cocoapods.org/pods/FSPhotoBrowser)
[![License](https://img.shields.io/cocoapods/l/FSPhotoBrowser.svg?style=flat)](http://cocoapods.org/pods/FSPhotoBrowser)
[![Platform](https://img.shields.io/cocoapods/p/FSPhotoBrowser.svg?style=flat)](http://cocoapods.org/pods/FSPhotoBrowser)

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

See the code snippet below for an example of how to implement the photo browser.

First create a photos array containing IDMPhoto objects:

``` objective-c
photo = [IDMPhoto photoWithFilePath:[[NSBundle mainBundle] pathForResource:@"newPhoto" ofType:@"jpg"]];
photo.captionFont = [UIFont fontWithName:@"verdana" size:14];
photo.titleFont = [UIFont fontWithName:@"Arial" size:20];
photo.title = @"Dev Divinity";
photo.caption = @"The London Eye is a giant Ferris ";
[photos addObject:photo];
```

There are two main ways to presente the photoBrowser, with a fade on screen or with a zooming effect from an existing view.

Using a simple fade transition:

``` objective-c    
IDMPhotoBrowser *browser = [[IDMPhotoBrowser alloc] initWithPhotos:photos];
``` 

Zooming effect from a view:

``` objective-c    
IDMPhotoBrowser *browser = [[IDMPhotoBrowser alloc] initWithPhotos:photos animatedFromView:sender];
```

When using this animation you can set the `scaleImage` property, in case the image from the view is not the same as the one that will be shown on the browser, so it will dynamically scale it:

``` objective-c    
browser.scaleImage = buttonSender.currentImage;
```

Presenting using a modal view controller:

``` objective-c
[self presentViewController:browser animated:YES completion:nil];
```

## Requirements

## Installation

FSPhotoBrowser is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "FSPhotoBrowser"
```

## Author

DevDivinity

## License

FSPhotoBrowser is available under the MIT license. See the LICENSE file for more info.
