//
//  MSAlertController.m
//  MSAlertController
//
//  Created by 鈴木 大貴 on 2014/11/14.
//  Copyright (c) 2014年 Taiki Suzuki. All rights reserved.
//

#import "MSAlertController.h"
#import <QuartzCore/QuartzCore.h>
#import <Accelerate/Accelerate.h>

#pragma mark - UIImage Category
@interface UIImage (Extension)

+ (UIImage *)imageWithColor:(UIColor *)color;
+ (UIImage *)screenshot;
- (UIImage *)bluredImage;
- (void)bluerdImageWithCompletion:(void(^)(UIImage *bluerdImage))completion;

@end

@implementation UIImage (Extension)

+ (UIImage *)imageWithColor:(UIColor *)color {
    CGRect frame = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContextWithOptions(frame.size, YES, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, frame);
    CGContextSaveGState(context);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)screenshot {
    CGSize imageSize = [UIScreen mainScreen].bounds.size;
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0f && UIInterfaceOrientationIsLandscape(orientation)) {
        imageSize = CGSizeMake([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
    }
    
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 2.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    for (UIWindow *window in [[UIApplication sharedApplication] windows]) {
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, window.center.x, window.center.y);
        CGContextConcatCTM(context, window.transform);
        CGContextTranslateCTM(context, -window.bounds.size.width * window.layer.anchorPoint.x, -window.bounds.size.height * window.layer.anchorPoint.y);
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0f) {
            if (orientation == UIInterfaceOrientationLandscapeLeft) {
                CGContextRotateCTM(context, M_PI_2);
                CGContextTranslateCTM(context, 0, -imageSize.width);
            } else if (orientation == UIInterfaceOrientationLandscapeRight) {
                CGContextRotateCTM(context, -M_PI_2);
                CGContextTranslateCTM(context, -imageSize.height, 0);
            } else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
                CGContextRotateCTM(context, M_PI);
                CGContextTranslateCTM(context, -imageSize.width, -imageSize.height);
            }
        }
        
        if ([window respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
            [window drawViewHierarchyInRect:window.bounds afterScreenUpdates:YES];
        } else {
            [window.layer renderInContext:context];
        }
        CGContextRestoreGState(context);
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage *)bluredImage {
    uint32_t boxSize = 0.15 * 100;
    boxSize = boxSize - (boxSize % 2) + 1;
    CGImageRef image = self.CGImage;
    vImage_Buffer inBuffer, outBuffer;
    vImage_Error error;
    void *pixelBuffer;
    CGDataProviderRef inProvider = CGImageGetDataProvider(image);
    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
    inBuffer.width = CGImageGetWidth(image);
    inBuffer.height = CGImageGetHeight(image);
    inBuffer.rowBytes = CGImageGetBytesPerRow(image);
    inBuffer.data = (void *)CFDataGetBytePtr(inBitmapData);
    
    pixelBuffer = malloc(CGImageGetBytesPerRow(image) * CGImageGetHeight(image));
    outBuffer.data = pixelBuffer;
    outBuffer.width = CGImageGetWidth(image);
    outBuffer.height = CGImageGetHeight(image);
    outBuffer.rowBytes = CGImageGetBytesPerRow(image);
    
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(outBuffer.data, outBuffer.width, outBuffer.height, 8, outBuffer.rowBytes, colorSpace, CGImageGetBitmapInfo(image));
    CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
    UIImage *bluredImage = [UIImage imageWithCGImage:imageRef];
    
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    
    free(pixelBuffer);
    CFRelease(inBitmapData);
    
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(imageRef);
    
    return bluredImage;
}

- (void)bluerdImageWithCompletion:(void(^)(UIImage *bluerdImage))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        UIImage *bluredImage = self.bluredImage;
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            if (completion) {
                completion(bluredImage);
            }
        });
    });
}

@end


#pragma mark - UITextField Category
@interface UITextField (Inset)

@end

@implementation UITextField (Inset)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, 5.0f, 0.0f);
}
#pragma clang diagnostic pop

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
- (CGRect)editingRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, 5.0f, 0.0f);
}
#pragma clang diagnostic pop

@end


#pragma mark - MSAlertAnimation Class
@interface MSAlertAnimation : NSObject <UIViewControllerAnimatedTransitioning>

@property (assign, nonatomic) BOOL isPresenting;

@end

@implementation MSAlertAnimation

static CGFloat const kAnimationDuration = 0.25f;

- (void)executePresentingAnimation:(id<UIViewControllerContextTransitioning>)transitionContext {
    CGSize windowSize = [UIScreen mainScreen].bounds.size;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0f) {
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        if (UIInterfaceOrientationIsLandscape(orientation)) {
            windowSize.width = [UIScreen mainScreen].bounds.size.height;
            windowSize.height = [UIScreen mainScreen].bounds.size.width;
        }
    }
    UIView *containerView = [transitionContext containerView];
    
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    toViewController.view.frame = CGRectMake(0.0f, 0.0f, windowSize.width, windowSize.height);
    toViewController.view.alpha = 0.0f;
    if ([toViewController isKindOfClass:[MSAlertController class]]) {
        MSAlertController* alertController = (MSAlertController *)toViewController;
        if (alertController.preferredStyle == MSAlertControllerStyleAlert) {
            alertController.tableViewContainer.transform = CGAffineTransformMakeScale(1.1f, 1.1f);
        }
    }
    [containerView addSubview:toViewController.view];
    
    [UIView animateWithDuration:kAnimationDuration delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^(void) {
        toViewController.view.alpha = 1.0f;
        if ([toViewController isKindOfClass:[MSAlertController class]]) {
            MSAlertController* alertController = (MSAlertController *)toViewController;
            if (alertController.preferredStyle == MSAlertControllerStyleAlert) {
                alertController.tableViewContainer.transform = CGAffineTransformIdentity;
            }
        }
    } completion:^(BOOL finished) {
        if (finished) {
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        }
    }];
}

- (void)executeDismissingAnimation:(id<UIViewControllerContextTransitioning>)transitionContext {
    CGSize windowSize = [UIScreen mainScreen].bounds.size;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0f) {
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        if (UIInterfaceOrientationIsLandscape(orientation)) {
            windowSize.width = [UIScreen mainScreen].bounds.size.height;
            windowSize.height = [UIScreen mainScreen].bounds.size.width;
        }
    }
    UIView *containerView = [transitionContext containerView];
    
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    toViewController.view.frame = CGRectMake(0.0f, 0.0f, windowSize.width, windowSize.height);
    [containerView insertSubview:toViewController.view belowSubview:fromViewController.view];
    
    [UIView animateWithDuration:kAnimationDuration delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^(void) {
        fromViewController.view.alpha = 0.0f;
    } completion:^(BOOL finished) {
        if (finished) {
            [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        }
    }];
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return kAnimationDuration;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    if(self.isPresenting){
        [self executePresentingAnimation:transitionContext];
    }
    else{
        [self executeDismissingAnimation:transitionContext];
    }
}

@end


#pragma mark - MSAlertAction Class
NSString *const kAlertActionChangeEnabledProperty = @"kAlertActionChangeEnabledProperty";

@interface MSAlertAction ()

typedef void (^MSAlertActionHandler)(MSAlertAction *action);

@property (strong, nonatomic) MSAlertActionHandler handler;
@property (copy, nonatomic) NSString *title;
@property (assign, nonatomic) MSAlertActionStyle style;

@end

@implementation MSAlertAction

static NSDictionary *_defaultFonts = nil;
static NSDictionary *_defaultColors = nil;

+ (instancetype)actionWithTitle:(NSString *)title style:(MSAlertActionStyle)style handler:(MSAlertActionHandler)handler {
    return [[[self class] alloc] initWithTitle:title style:style handler:handler];
}

- (id)initWithTitle:(NSString *)title style:(MSAlertActionStyle)style handler:(MSAlertActionHandler)handler {
    self = [super init];
    if (self) {
        static dispatch_once_t token;
        dispatch_once(&token, ^(void) {
            _defaultFonts = @{
                              @(MSAlertActionStyleDestructive): [UIFont fontWithName:@"HelveticaNeue" size:18.0f],
                              @(MSAlertActionStyleDefault): [UIFont fontWithName:@"HelveticaNeue" size:18.0f],
                              @(MSAlertActionStyleCancel): [UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0f]
                              };
            
            _defaultColors = @{
                               @(MSAlertActionStyleDestructive): [UIColor colorWithRed:1.0f green:59.0f/255.0f blue:48.0f/255.0f alpha:1.0f],
                               @(MSAlertActionStyleDefault): [UIColor colorWithRed:0.0f green:122.0f/255.0f blue:1.0f alpha:1.0f],
                               @(MSAlertActionStyleCancel): [UIColor colorWithRed:0.0f green:122.0f/255.0f blue:1.0f alpha:1.0f]
                               };
        });
        
        
        self.handler = handler;
        self.style = style;
        self.title = title;
        self.font = [self.defaultFonts objectForKey:@(style)];
        self.titleColor = [self.defaultColors objectForKey:@(style)];
        self.enabled = YES;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    MSAlertAction *clone = [[[self class] allocWithZone:zone] initWithTitle:_title style:_style handler:_handler];
    self.font = [_font copyWithZone:zone];
    self.titleColor = [_titleColor copyWithZone:zone];
    self.enabled = _enabled;
    return clone;
}

- (void)setEnabled:(BOOL)enabled {
    BOOL previousValue = self.enabled;
    _enabled = enabled;
    if (previousValue != self.enabled) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kAlertActionChangeEnabledProperty object:nil];
    }
}

- (NSDictionary *)defaultFonts {
    return _defaultFonts;
}

- (NSDictionary *)defaultColors {
    return _defaultColors;
}

@end


#pragma mark - MSAlertController Class
@interface MSAlertController () <UIViewControllerTransitioningDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate> {
    UIColor *disabledColor;
}

@property (assign, nonatomic) MSAlertControllerStyle preferredStyle;
@property (copy, nonatomic) NSArray *actions;
@property (copy, nonatomic) NSArray *textFields;
@property (strong, nonatomic) MSAlertAnimation *animation;
@property (strong, nonatomic) UIButton *cancelButton;

// Views on Alert Controller
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic, readwrite) IBOutlet UIView *tableViewContainer;
@property (weak, nonatomic) IBOutlet UITableView *tableView;


// Views on Table View
@property (strong, nonatomic) IBOutlet UIView *tableViewHeader;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIView *textFieldContentView;


// Constraints of Table View Header
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *superviewTitleConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleMessageConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageHeightConstraint;
// Only use when Alert Style
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageTextFieldConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textFieldHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textFieldSuperviewConstraint;
// Only use when Action Sheet Style
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageSuperviewConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewContainerHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewContarinerSuperviewConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewBottomSpaceConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewContainerWidthConstraint;


// Constraints of Table View
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewContainerBottomSpaceConstraint;

@end

@implementation MSAlertController

static NSString *const kCellReuseIdentifier = @"Cell";
static NSString *const kAlertControllerNameActionSheet = @"MSAlertController_ActionSheet";
static NSString *const kAlertControllerNameAlert = @"MSAlertController";

static CGFloat const kTextFieldHeight = 20.0f;
static CGFloat const kTextFieldWidth = 234.0f;

+ (instancetype)alertControllerWithTitle:(NSString *)title message:(NSString *)message preferredStyle:(MSAlertControllerStyle)preferredStyle {
    return [[[self class] alloc] initWithTitle:title message:message preferredStyle:preferredStyle];
}

- (id)initWithTitle:(NSString *)title message:(NSString *)message preferredStyle:(MSAlertControllerStyle)preferredStyle {
    NSString *nibName = nil;
    switch (preferredStyle) {
        case MSAlertControllerStyleActionSheet:
            nibName = kAlertControllerNameActionSheet;
            break;
        case MSAlertControllerStyleAlert:
            nibName = kAlertControllerNameAlert;
            break;
    }
    
    self = [super initWithNibName:nibName bundle:nil];
    if (self) {
        self.transitioningDelegate = self;
        
        self.title = title;
        self.message = message;
        
        if (preferredStyle == MSAlertControllerStyleAlert) {
            self.titleColor = [UIColor blackColor];
            self.titleFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:16.0f];
            self.messageColor = [UIColor blackColor];
            self.messageFont = [UIFont fontWithName:@"HelveticaNeue" size:14.0f];
        } else {
            self.titleColor = [UIColor colorWithRed:143.0f/255.0f green:143.0f/255.0f blue:143.0f/255.0f alpha:1.0f];
            self.titleFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0f];
            self.messageColor = [UIColor colorWithRed:143.0f/255.0f green:143.0f/255.0f blue:143.0f/255.0f alpha:1.0f];;
            self.messageFont = [UIFont fontWithName:@"HelveticaNeue" size:13.0f];
        }
        
        self.actions = [NSArray array];
        self.textFields = [NSArray array];
        self.animation = [[MSAlertAnimation alloc] init];
        self.preferredStyle = preferredStyle;
        self.enabledBlurEffect = YES;
        self.backgroundColor = [UIColor grayColor];
        self.alpha = 0.5f;
        self.alertBackgroundColor = [UIColor whiteColor];
        self.separatorColor = [UIColor colorWithRed:231.0f/255.0f green:231.0f/255.0f blue:233.0f/255.0f alpha:1.0f];
        
        disabledColor = [UIColor colorWithRed:131.0f/255.0f green:131.0f/255.0f blue:131.0f/255.0f alpha:1.0f];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(relaodTableView:)
                                                 name:kAlertActionChangeEnabledProperty
                                               object:nil];
    
    self.view.frame = [UIScreen mainScreen].bounds;
    
    self.tableView.layer.cornerRadius = 6.0f;
    self.tableView.layer.masksToBounds = YES;
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellReuseIdentifier];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorInset = UIEdgeInsetsZero;
    if ([self.tableView respondsToSelector:@selector(layoutMargins)]) {
        self.tableView.layoutMargins = UIEdgeInsetsZero;
    }
    self.tableView.scrollEnabled = NO;
    self.tableViewContainer.backgroundColor = [UIColor clearColor];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    UIImage *screenshot = [UIImage screenshot];
    if (self.enabledBlurEffect) {
        self.imageView.image = screenshot.bluredImage;
    } else {
        self.imageView.image = screenshot;
    }
    
    self.tableView.separatorColor = self.separatorColor;
    
    self.backgroundView.backgroundColor = self.backgroundColor;
    self.backgroundView.alpha = self.alpha;
    
    self.titleLabel.text = self.title;
    self.titleLabel.textColor = self.titleColor;
    self.titleLabel.font = self.titleFont;
    
    self.messageLabel.text = self.message;
    self.messageLabel.textColor = self.messageColor;
    self.messageLabel.font = self.messageFont;
    
    NSInteger textFieldCount = self.textFields.count;
    self.textFieldHeightConstraint.constant = textFieldCount * kTextFieldHeight;
    self.textFieldContentView.backgroundColor = [UIColor whiteColor];
    [self.textFields enumerateObjectsUsingBlock:^(UITextField *textField, NSUInteger index, BOOL *stop) {
        CGRect textFieldFrame = textField.frame;
        textFieldFrame.origin.y = index * kTextFieldHeight;
        textField.frame = textFieldFrame;
        [self.textFieldContentView addSubview:textField];
    }];
    
    if (self.preferredStyle == MSAlertControllerStyleActionSheet) {
        CGSize windowSize = [UIScreen mainScreen].bounds.size;
        CGFloat width = windowSize.width;
        if (width > windowSize.height) {
            width = windowSize.height;
        }
        width -= 16.0f;
        self.tableViewContainerWidthConstraint.constant = width;
    }
    
    NSDictionary *options = @{ NSFontAttributeName : self.titleFont };
    CGRect boundingRect = [self.titleLabel.text boundingRectWithSize:CGSizeMake(kTextFieldWidth, NSIntegerMax)
                                                                options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                             attributes:options context:nil];
    self.titleHeightConstraint.constant = boundingRect.size.height;
    
    options = @{ NSFontAttributeName : self.messageFont };
    boundingRect = [self.messageLabel.text boundingRectWithSize:CGSizeMake(kTextFieldWidth, NSIntegerMax)
                                                             options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                          attributes:options context:nil];
    self.messageHeightConstraint.constant = boundingRect.size.height;
    
    CGFloat headerHeight = 0.0f;
    headerHeight += self.superviewTitleConstraint.constant;
    headerHeight += self.titleHeightConstraint.constant;
    headerHeight += self.titleMessageConstraint.constant;
    headerHeight += self.messageHeightConstraint.constant;
    if (self.preferredStyle == MSAlertControllerStyleAlert) {
        headerHeight += self.messageTextFieldConstraint.constant;
        headerHeight += self.textFieldHeightConstraint.constant;
        if (self.textFields.count < 1) {
            self.textFieldSuperviewConstraint.constant = 0.0f;
        }
        headerHeight += self.textFieldSuperviewConstraint.constant;
    } else {
        headerHeight += self.messageSuperviewConstraint.constant;
    }
    
    CGRect headerFrame = self.tableViewHeader.frame;
    headerFrame.size.height = headerHeight;
    self.tableViewHeader.frame = headerFrame;
    
    
    if (self.preferredStyle == MSAlertControllerStyleAlert) {
        CGFloat tableViewHeight = self.actions.count * 44.0f;
        self.tableViewHeightConstraint.constant = tableViewHeight + headerHeight - 1.0f;
    } else {
        NSInteger actionCount = self.actions.count;
        MSAlertAction *cancelAction = [self cancelAction];
        if (cancelAction != nil) {
            actionCount--;
        }
        CGFloat tableViewHeight = actionCount * 44.0f;
        if (cancelAction != nil) {
            self.tableViewBottomSpaceConstraint.constant = 52.0f;
            
            self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
            self.cancelButton.userInteractionEnabled = cancelAction.enabled;
            self.cancelButton.layer.cornerRadius = 6.0f;
            self.cancelButton.layer.masksToBounds = YES;
            [self.cancelButton setTitle:cancelAction.title forState:UIControlStateNormal];
            if (cancelAction.enabled) {
                [self.cancelButton setTitleColor:cancelAction.titleColor forState:UIControlStateNormal];
            } else {
                [self.cancelButton setTitleColor:disabledColor forState:UIControlStateNormal];
            }
            self.cancelButton.titleLabel.font = cancelAction.font;
            [self.cancelButton addTarget:self action:@selector(cancelButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [self.tableViewContainer addSubview:self.cancelButton];
            
            self.cancelButton.translatesAutoresizingMaskIntoConstraints = NO;
            [self.cancelButton addConstraint:[NSLayoutConstraint constraintWithItem:self.cancelButton
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeHeight
                                                             multiplier:1.0
                                                               constant:44.0f]];
            
            [self.tableViewContainer addConstraint:[NSLayoutConstraint constraintWithItem:self.cancelButton
                                                                  attribute:NSLayoutAttributeLeft
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.tableViewContainer
                                                                  attribute:NSLayoutAttributeLeft
                                                                 multiplier:1.0
                                                                   constant:0]];
            
            [self.tableViewContainer addConstraint:[NSLayoutConstraint constraintWithItem:self.cancelButton
                                                                                attribute:NSLayoutAttributeRight
                                                                                relatedBy:NSLayoutRelationEqual
                                                                                   toItem:self.tableViewContainer
                                                                                attribute:NSLayoutAttributeRight
                                                                               multiplier:1.0
                                                                                 constant:0]];
            
            [self.tableViewContainer addConstraint:[NSLayoutConstraint constraintWithItem:self.cancelButton
                                                                                attribute:NSLayoutAttributeTop
                                                                                relatedBy:NSLayoutRelationEqual
                                                                                   toItem:self.tableView
                                                                                attribute:NSLayoutAttributeBottom
                                                                               multiplier:1.0
                                                                                 constant:8.0f]];
        }
        
        self.tableViewContainerHeightConstraint.constant = tableViewHeight + headerHeight + self.tableViewBottomSpaceConstraint.constant - 0.5f;
        self.tableViewContarinerSuperviewConstraint.constant = -self.tableViewContainerHeightConstraint.constant;
    }
    
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = self.separatorColor;
    [self.tableViewHeader addSubview:line];
    
    line.translatesAutoresizingMaskIntoConstraints = NO;
    [line addConstraint:[NSLayoutConstraint constraintWithItem:line
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeHeight
                                                    multiplier:1.0
                                                      constant:0.5f]];
    
    [self.tableViewHeader addConstraint:[NSLayoutConstraint constraintWithItem:line
                                                                        attribute:NSLayoutAttributeLeft
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.tableViewHeader
                                                                        attribute:NSLayoutAttributeLeft
                                                                       multiplier:1.0
                                                                         constant:0]];
    
    [self.tableViewHeader addConstraint:[NSLayoutConstraint constraintWithItem:line
                                                                        attribute:NSLayoutAttributeRight
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.tableViewHeader
                                                                        attribute:NSLayoutAttributeRight
                                                                       multiplier:1.0
                                                                         constant:0]];
    
    [self.tableViewHeader addConstraint:[NSLayoutConstraint constraintWithItem:line
                                                                        attribute:NSLayoutAttributeBottom
                                                                        relatedBy:NSLayoutRelationEqual
                                                                           toItem:self.tableViewHeader
                                                                        attribute:NSLayoutAttributeBottom
                                                                       multiplier:1.0
                                                                         constant:0]];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    if (self.preferredStyle == MSAlertControllerStyleActionSheet && [self cancelAction] != nil) {
        UIImage *normalImage = [UIImage imageWithColor:self.alertBackgroundColor];
        [self.cancelButton setBackgroundImage:normalImage forState:UIControlStateNormal];
        UIImage *highlightedImage = [UIImage imageWithColor:[UIColor colorWithRed:217.0f/255.0f green:217.0f/255.0f blue:217.0f/255.0f alpha:1.0f]];
        [self.cancelButton setBackgroundImage:highlightedImage forState:UIControlStateHighlighted];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.preferredStyle == MSAlertControllerStyleActionSheet) {
        self.tableViewContarinerSuperviewConstraint.constant = 8.0f;
        [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^(void) {
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {}];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.preferredStyle == MSAlertControllerStyleActionSheet) {
        self.tableViewContarinerSuperviewConstraint.constant = -self.tableViewContainerHeightConstraint.constant;
        [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^(void) {
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {}];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *userInfo = notification.userInfo;
    CGSize kbSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    self.tableViewContainerBottomSpaceConstraint.constant = kbSize.height;
    [UIView animateWithDuration:0.3 animations:^(void) {
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    self.tableViewContainerBottomSpaceConstraint.constant = 0.0f;
    [UIView animateWithDuration:0.3 animations:^(void) {
        [self.view layoutIfNeeded];
    }];
}

- (MSAlertAction *)cancelAction {
    for (MSAlertAction *action in self.actions) {
        if (action.style == MSAlertActionStyleCancel) {
            return action;
        }
    }
    return nil;
}

- (void)relaodTableView:(NSNotification *)notification {
    [self.tableView reloadData];
}

- (void)cancelButtonTapped:(id)sender {
    MSAlertAction *action = [self cancelAction];
    if ([action isKindOfClass:[MSAlertAction class]] && action.handler) {
        action.handler(action);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - MSAlertController Public Methods
- (void)addTextFieldWithConfigurationHandler:(void (^)(UITextField *))configurationHandler {
    if (self.preferredStyle == MSAlertControllerStyleActionSheet) {
        [NSException raise:@"NSInternalInconsistencyException" format:@"Text fields can only be added to an alert controller of style MSAlertControllerStyleAlert"];
        return;
    }

    NSMutableArray *textFields = self.textFields.mutableCopy;
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, kTextFieldWidth, kTextFieldHeight)];
    textField.borderStyle = UITextBorderStyleNone;
    textField.layer.borderWidth = 0.5f;
    textField.layer.borderColor = [UIColor grayColor].CGColor;
    textField.delegate = self;
    if (configurationHandler) {
        configurationHandler(textField);
    }
    [textFields addObject:textField];
    self.textFields = textFields.copy;
}

- (void)addAction:(MSAlertAction *)action {
    NSMutableArray *actions = self.actions.mutableCopy;
    if (action.style == MSAlertActionStyleCancel) {
        for (MSAlertAction *aa in actions) {
            if (aa.style == MSAlertActionStyleCancel) {
                [NSException raise:@"NSInternalInconsistencyException" format:@"MSAlertController can only have one action with a style of MSAlertActionStyleCancel"];
                return;
            }
        }
    }
    
    [actions addObject:action];
    [actions enumerateObjectsUsingBlock:^(MSAlertAction *aa, NSUInteger index, BOOL *stop) {
        NSUInteger lastIndex = actions.count - 1;
        if (aa.style == MSAlertActionStyleCancel && lastIndex != index) {
            [actions exchangeObjectAtIndex:index withObjectAtIndex:lastIndex];
            *stop = YES;
            return;
        }
    }];
    self.actions = actions.copy;
}

#pragma mark - UIViewControllerTransitioningDelegate Methods
- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    self.animation.isPresenting = YES;
    return self.animation;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    self.animation.isPresenting = NO;
    return self.animation;
}

#pragma mark - UITableViewDataSource Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.preferredStyle == MSAlertControllerStyleActionSheet && [self cancelAction] != nil) {
        return self.actions.count - 1;
    }
    return self.actions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellReuseIdentifier];
    
    MSAlertAction *action = [self.actions objectAtIndex:indexPath.row];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, cell.frame.size.height)];
    titleLabel.text = action.title;
    titleLabel.textColor = action.titleColor;
    titleLabel.font = action.font;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [cell.contentView addSubview:titleLabel];
    
    titleLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
    
    cell.separatorInset = UIEdgeInsetsZero;
    if ([cell respondsToSelector:@selector(layoutMargins)]) {
        cell.layoutMargins = UIEdgeInsetsZero;
    }
    
    cell.userInteractionEnabled = action.enabled;
    if (!action.enabled) {
        titleLabel.textColor = disabledColor;
    }
    
    if (action.normalColor) {
        cell.backgroundColor = action.normalColor;
    } else {
        cell.backgroundColor = self.alertBackgroundColor;
    }
    
    if (action.highlightedColor) {
        UIView *selectedBackgroundView = [[UIView alloc] init];
        selectedBackgroundView.backgroundColor = action.highlightedColor;
        cell.selectedBackgroundView = selectedBackgroundView;
    }
        
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

#pragma mark - UITableViewDelegate Methods
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return CGRectGetHeight(self.tableViewHeader.frame);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    self.tableViewHeader.backgroundColor = self.alertBackgroundColor;
    return self.tableViewHeader;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    MSAlertAction *action = [self.actions objectAtIndex:indexPath.row];
    if ([action isKindOfClass:[MSAlertAction class]] && action.handler) {
        action.handler(action);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITextFieldDelegate Methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([textField canResignFirstResponder]) {
        [textField resignFirstResponder];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
    return YES;
}

@end