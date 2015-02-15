//
//  MSAlertController.h
//  MSAlertController
//
//  Created by 鈴木 大貴 on 2014/11/14.
//  Copyright (c) 2014年 Taiki Suzuki. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MSAlertActionStyle) {
    MSAlertActionStyleDefault = 0,
    MSAlertActionStyleCancel,
    MSAlertActionStyleDestructive
};

typedef NS_ENUM(NSInteger, MSAlertControllerStyle) {
    MSAlertControllerStyleActionSheet = 0,
    MSAlertControllerStyleAlert
};

@interface MSAlertAction : NSObject <NSCopying>

@property (copy, nonatomic, readonly) NSString *title;
@property (assign, nonatomic, readonly) MSAlertActionStyle style;
@property (assign, nonatomic) BOOL enabled;
@property (strong, nonatomic) UIColor *titleColor;
@property (strong, nonatomic) UIFont *font;
@property (strong, nonatomic) UIColor *normalColor;
@property (strong, nonatomic) UIColor *highlightedColor;

+ (instancetype)actionWithTitle:(NSString *)title style:(MSAlertActionStyle)style handler:(void (^)(MSAlertAction *action))handler;

@end


@interface MSAlertController : UIViewController

// Views on Alert Controller
@property (weak, nonatomic, readonly) IBOutlet UIView *tableViewContainer;

@property (copy, nonatomic, readonly) NSArray *actions;
@property (copy, nonatomic, readonly) NSArray *textFields;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *message;
@property (assign, nonatomic, readonly) MSAlertControllerStyle preferredStyle;
@property (strong, nonatomic) UIColor *titleColor;
@property (strong, nonatomic) UIFont *titleFont;
@property (strong, nonatomic) UIColor *messageColor;
@property (strong, nonatomic) UIFont *messageFont;
@property (assign, nonatomic) BOOL enabledBlurEffect;
@property (strong, nonatomic) UIColor *backgroundColor;
@property (assign, nonatomic) CGFloat alpha;
@property (strong, nonatomic) UIColor *alertBackgroundColor;
@property (strong, nonatomic) UIColor *separatorColor;

+ (instancetype)alertControllerWithTitle:(NSString *)title message:(NSString *)message preferredStyle:(MSAlertControllerStyle)preferredStyle;
- (void)addTextFieldWithConfigurationHandler:(void (^)(UITextField *textField))configurationHandler;
- (void)addAction:(MSAlertAction *)action;

@end