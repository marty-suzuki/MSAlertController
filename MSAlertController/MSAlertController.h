//
//  MSAlertController.h
//  MSAlertController
//
//  Created by 鈴木 大貴 on 2014/11/14.
//  Copyright (c) 2014年 Taiki Suzuki. All rights reserved.
//

#import <UIKit/UIKit.h>

FOUNDATION_EXTERN NSString *const kAlertActionChangeEnabledProperty;

typedef NS_ENUM(NSInteger, MSAlertActionStyle) {
    MSAlertActionStyleDefault = 0,
    MSAlertActionStyleCancel,
    MSAlertActionStyleDestructive
};

typedef NS_ENUM(NSInteger, MSAlertControllerStyle) {
    MSAlertControllerStyleActionSheet = 0,
    MSAlertControllerStyleAlert
};

@class MSAlertAction, MSAlertAnimation, MSAlertHeaderView, MSActionSheetHeaderView, SABlurImageView;
@interface MSAlertController : UIViewController

// Views on Alert Controller
//@property (weak, nonatomic, readonly) IBOutlet UIView *tableViewContainer;

//@property (copy, nonatomic, readonly) NSArray *actions;
//@property (copy, nonatomic, readonly) NSArray *textFields;
//@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *message;
//@property (assign, nonatomic, readonly) MSAlertControllerStyle preferredStyle;
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
//- (void)addTextFieldWithConfigurationHandler:(void (^)(UITextField *textField))configurationHandler;
//- (void)addAction:(MSAlertAction *)action;


//MARK: - Private properties
@property (assign, nonatomic) MSAlertControllerStyle preferredStyle;
@property (copy, nonatomic) NSArray *actions;
@property (copy, nonatomic) NSArray *textFields;
@property (strong, nonatomic) MSAlertAnimation *animation;
@property (strong, nonatomic) UIButton *cancelButton;

// Views on Alert Controller
@property (weak, nonatomic) IBOutlet SABlurImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic, readwrite) IBOutlet UIView *tableViewContainer;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

// Views on Table View
@property (weak, nonatomic) UIView *tableViewHeader;
@property (weak, nonatomic) UILabel *titleLabel;
@property (weak, nonatomic) UILabel *messageLabel;

// Constraints of Table View Header
@property (weak, nonatomic) NSLayoutConstraint *superviewTitleConstraint;
@property (weak, nonatomic) NSLayoutConstraint *titleHeightConstraint;
@property (weak, nonatomic) NSLayoutConstraint *titleMessageConstraint;
@property (weak, nonatomic) NSLayoutConstraint *messageHeightConstraint;

// Only use when Alert Style
@property (strong, nonatomic) MSAlertHeaderView *__nullable alertHeaderView;
@property (weak, nonatomic) NSLayoutConstraint *messageTextFieldConstraint;
@property (weak, nonatomic) NSLayoutConstraint *textFieldHeightConstraint;
@property (weak, nonatomic) NSLayoutConstraint *textFieldSuperviewConstraint;

// Only use when Action Sheet Style
@property (strong, nonatomic) MSActionSheetHeaderView *__nullable actionSheetHeaderView;
@property (weak, nonatomic) NSLayoutConstraint *messageSuperviewConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewContainerHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewContarinerSuperviewConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewBottomSpaceConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewContainerWidthConstraint;

// Constraints of Table View
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewContainerBottomSpaceConstraint;

- (MSAlertAction *)cancelAction;

@end