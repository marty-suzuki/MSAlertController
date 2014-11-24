# MSAlertController

[![CI Status](http://img.shields.io/travis/Taiki Suzuki/MSAlertController.svg?style=flat)](https://travis-ci.org/Taiki Suzuki/MSAlertController)
[![Version](https://img.shields.io/cocoapods/v/MSAlertController.svg?style=flat)](http://cocoadocs.org/docsets/MSAlertController)
[![License](https://img.shields.io/cocoapods/l/MSAlertController.svg?style=flat)](http://cocoadocs.org/docsets/MSAlertController)
[![Platform](https://img.shields.io/cocoapods/p/MSAlertController.svg?style=flat)](http://cocoadocs.org/docsets/MSAlertController)

## You can use AlertController in iOS7!!
#### MSAlertController has same feature at UIAlertViewController.
- Alert
- ActionSheet

#### In addtion, customize font, font size and font color.

![Alert](./Raw/images/alert.png)
![Action_sheet](./Raw/images/action_sheet.png)


## Usage
To run the example project, clone the repo, and run `pod install` from the Example directory first.


#### For Alert
Set ```MSAlertControllerStyleAlert``` to preferredStyle.


``` objective-c

	MSAlertController *alertController = [MSAlertController alertControllerWithTitle:@"MSAlertController" message:@"This is MSAlertController." preferredStyle:MSAlertControllerStyleAlert];
    
    MSAlertAction *action = [MSAlertAction actionWithTitle:@"Cancel" style:MSAlertActionStyleCancel handler:^(MSAlertAction *action) {
        //Write a code for this action.
    }];
    [alertController addAction:action];
    
    MSAlertAction *action2 = [MSAlertAction actionWithTitle:@"Destructive" style:MSAlertActionStyleDestructive handler:^(MSAlertAction *action) {
        //Write a code for this action.
    }];
    [alertController addAction:action2];
    
    MSAlertAction *action3 = [MSAlertAction actionWithTitle:@"Default" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action) {
        //Write a code for this action.
    }];
    [alertController addAction:action3];
    
    [self presentViewController:alertController animated:YES completion:nil];
	
```


#### For Action Sheet
Set ```MSAlertControllerStyleActionSheet``` to preferredStyle.


``` objective-c

	MSAlertController *alertController = [MSAlertController alertControllerWithTitle:@"MSAlertController" message:@"This is MSAlertController." preferredStyle:MSAlertControllerStyleActionSheet];
    
    MSAlertAction *action = [MSAlertAction actionWithTitle:@"Cancel" style:MSAlertActionStyleCancel handler:^(MSAlertAction *action) {
        //Write a code for this action.
    }];
    [alertController addAction:action];
    
    MSAlertAction *action2 = [MSAlertAction actionWithTitle:@"Destructive" style:MSAlertActionStyleDestructive handler:^(MSAlertAction *action) {
        //Write a code for this action.
    }];
    [alertController addAction:action2];
    
    MSAlertAction *action3 = [MSAlertAction actionWithTitle:@"Default" style:MSAlertActionStyleDefault handler:^(MSAlertAction *action) {
        //Write a code for this action.
    }];
    [alertController addAction:action3];
    
    [self presentViewController:alertController animated:YES completion:nil];
	
```


## Customization
#### For Action Controller
``` objective-c
@property (strong, nonatomic) UIColor *titleColor;
@property (strong, nonatomic) UIFont *titleFont;
@property (strong, nonatomic) UIColor *messageColor;
@property (strong, nonatomic) UIFont *messageFont;
@property (assign, nonatomic) BOOL enabledBlurEffect;
@property (strong, nonatomic) UIColor *backgroundColor;
@property (assign, nonatomic) CGFloat alpha;
```

![Alert Controller](./Raw/images/alert_controller_custom.png)

``` objective-c
MSAlertController *alertController = [MSAlertController alertControllerWithTitle:@"MSAlertController" message:@"This is MSAlertController." preferredStyle:MSAlertControllerStyleAlert];
alertController.titleColor = [UIColor blueColor];
alertController.titleFont = [UIFont fontWithName:@"Baskerville-BoldItalic" size:20.0f];
alertController.messageColor = [UIColor greenColor];
alertController.messageFont = [UIFont fontWithName:@"Baskerville-BoldItalic" size:18.0f];
```


#### For Action
``` objective-c
@property (strong, nonatomic) UIColor *titleColor;
@property (strong, nonatomic) UIFont *font;
```

![Action](./Raw/images/action_custom.png)

``` objective-c
MSAlertAction *action = [MSAlertAction actionWithTitle:@"Cancel" style:MSAlertActionStyleCancel handler:^(MSAlertAction *action) {
    //Write a code for this action.
}];
action.titleColor = [UIColor redColor];
action.font = [UIFont fontWithName:@"Baskerville-BoldItalic" size:18.0f];
[alertController addAction:action];
```


## Requirements
- iOS 7.0 and greater
- ARC
- QuartzCore.framework

## Installation

MSAlertController is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "MSAlertController"

## Author

Taiki Suzuki, s1180183@gmail.com

## License

MSAlertController is available under the MIT license. See the LICENSE file for more info.

